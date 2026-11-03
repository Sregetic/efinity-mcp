"""Shared 32x32 grayscale -> 8x8 gray/edge occupancy feature contract."""
import numpy as np
from PIL import Image

CLASSES=('blank','circle','rectangle','triangle')

def gray_roi(image,roi):
    x,y,w,h=roi
    if w<1 or h<1 or x<0 or y<0 or x+w>image.width or y+h>image.height:
        raise ValueError('Card ROI must fit the source image')
    # Match hardware's origin-aligned floor sampling, not PIL's center sampling.
    source=np.asarray(image.convert('RGB'),dtype=np.uint16)
    yy=y+(np.arange(32)*h)//32;xx=x+(np.arange(32)*w)//32
    rgb=source[yy[:,None],xx[None,:]]
    return ((77*rgb[:,:,0]+150*rgb[:,:,1]+29*rgb[:,:,2])>>8).astype(np.uint8)

def features(gray):
    if gray.shape!=(32,32) or gray.dtype!=np.uint8:raise ValueError('Expected uint8[32,32] grayscale tensor')
    g=gray.astype(np.int16);dx=np.zeros_like(g);dy=np.zeros_like(g)
    dx[:,1:]=g[:,1:]-g[:,:-1];dy[1:,:]=g[1:,:]-g[:-1,:]
    edge=(np.abs(dx)+np.abs(dy)>=32)
    blocks=gray.reshape(8,4,8,4);eb=edge.reshape(8,4,8,4)
    return (np.concatenate([(blocks.sum(axis=(1,3))//16).ravel(),(eb.sum(axis=(1,3))*255//16).ravel()]).astype(np.int16)-128).astype(np.int8)

def requantize(value,multiplier,shift):
    # Exact TFLITE_SINGLE_ROUNDING contract, including negative ties.
    total_shift=31-shift
    return (int(value)*int(multiplier)+(1<<(total_shift-1)))>>total_shift

def dense(x,w,b,input_zero,output_zero,multiplier,shift,relu=False):
    acc=(w.astype(np.int64)@(x.astype(np.int64)-input_zero))+b.astype(np.int64)
    y=np.array([requantize(v,multiplier,shift)+output_zero for v in acc],dtype=np.int64)
    return np.clip(y,output_zero if relu else -128,127).astype(np.int8)
