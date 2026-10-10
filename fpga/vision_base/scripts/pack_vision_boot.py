"""Pack the existing validated DDR ELF and weights for Flash 0x700000..0x7fffff."""
import argparse,json,struct,zlib
from pathlib import Path
from load_vision_ddr import validate_image

FLASH_ADDRESS=0x700000
FLASH_LIMIT=0x800000

def validate_package(data):
 if len(data)<32:raise ValueError('Truncated SPI boot header')
 h=struct.unpack_from('<8I',data)
 if h[0:2]!=(0x56424f31,1) or h[3]!=0x07000000 or not h[2] or h[2]>0x400000 or h[4]>0x200000 or len(data)!=32+h[2]+h[4] or len(data)>FLASH_LIMIT-FLASH_ADDRESS:
  raise ValueError('Invalid SPI boot header, address or length')
 if h[7]!=zlib.crc32(data[:28]) or h[5]!=zlib.crc32(data[32:32+h[2]]) or h[6]!=zlib.crc32(data[32+h[2]:]):raise ValueError('SPI boot CRC mismatch')
 return h

def pack(elf,weights):
 entry,segments,sym=validate_image(elf,weights)
 if entry!=sym['__app_start']:raise ValueError('SPI boot requires the existing _start entry at application base')
 data=elf.read_bytes();end=max(s['address']+s['size'] for s in segments)
 app=bytearray(end-sym['__app_start'])
 for s in segments:
  i=s['address']-sym['__app_start'];app[i:i+s['size']]=data[s['offset']:s['offset']+s['size']]
 w=weights.read_bytes()
 header=struct.pack('<7I',0x56424f31,1,len(app),entry,len(w),zlib.crc32(app),zlib.crc32(w))
 image=header+struct.pack('<I',zlib.crc32(header))+app+w
 if len(image)>FLASH_LIMIT-FLASH_ADDRESS:raise ValueError('Application/weights exceed reserved 1MiB Flash partition')
 validate_package(image)
 return image

def main():
 p=argparse.ArgumentParser();p.add_argument('--elf',type=Path,required=True);p.add_argument('--weights',type=Path,required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args()
 data=pack(a.elf,a.weights);a.output.parent.mkdir(parents=True,exist_ok=True);a.output.write_bytes(data)
 a.output.with_suffix('.hex').write_text(''.join(f'{b:02X}\n' for b in data))
 record=dict(address=FLASH_ADDRESS,limit=FLASH_LIMIT,image_bytes=len(data),format='VBO1 version1 header32, flat DDR app, weights; independent CRC32',elf=str(a.elf.resolve()),weights=str(a.weights.resolve()),configuration_flash_written=False)
 a.output.with_suffix('.json').write_text(json.dumps(record,indent=2));print(json.dumps(record,indent=2))
if __name__=='__main__':main()
