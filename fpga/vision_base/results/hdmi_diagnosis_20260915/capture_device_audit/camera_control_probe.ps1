Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
using System.Runtime.InteropServices.ComTypes;
[ComImport,Guid("29840822-5B84-11D0-BD3B-00A0C911CE86"),InterfaceType(ComInterfaceType.InterfaceIsIUnknown)] interface IDevEnum { [PreserveSig]int CreateClassEnumerator(ref Guid g,out IEnumMoniker e,int flags); }
[ComImport,Guid("55272A00-42CB-11CE-8135-00AA004BB851"),InterfaceType(ComInterfaceType.InterfaceIsIUnknown)] interface IBag { [PreserveSig]int Read([MarshalAs(UnmanagedType.LPWStr)]string n,[MarshalAs(UnmanagedType.Struct)]out object v,IntPtr err); [PreserveSig]int Write([MarshalAs(UnmanagedType.LPWStr)]string n,ref object v); }
[ComImport,Guid("C6E13370-30AC-11D0-A18C-00A0C9118956"),InterfaceType(ComInterfaceType.InterfaceIsIUnknown)] interface ICam { [PreserveSig]int GetRange(int p,out int min,out int max,out int step,out int def,out int flags);[PreserveSig]int Set(int p,int v,int flags);[PreserveSig]int Get(int p,out int v,out int flags); }
public static class CameraQuery {
 public static void Run(){
 object o=Activator.CreateInstance(Type.GetTypeFromCLSID(new Guid("62BE5D10-60EB-11D0-BD3B-00A0C911CE86")));IEnumMoniker en;Guid cat=new Guid("860BB310-5D01-11D0-BD3B-00A0C911CE86");((IDevEnum)o).CreateClassEnumerator(ref cat,out en,0);var arr=new IMoniker[1];
 while(en.Next(1,arr,IntPtr.Zero)==0){object bag;Guid bg=typeof(IBag).GUID;arr[0].BindToStorage(null,null,ref bg,out bag);object name;((IBag)bag).Read("FriendlyName",out name,IntPtr.Zero);
 if((string)name=="UGREEN 25854") {object filter;Guid fg=new Guid("56A86895-0AD4-11CE-B03A-0020AF0BA770");arr[0].BindToObject(null,null,ref fg,out filter);Console.WriteLine(name);try{ICam cam=(ICam)filter;foreach(int p in new[]{4,7,8}){int min,max,step,def,flags,v;int hr=cam.GetRange(p,out min,out max,out step,out def,out flags);Console.WriteLine("CameraControl property="+p+" range_hr=0x"+hr.ToString("X8"));if(hr>=0){int hg=cam.Get(p,out v,out flags);Console.WriteLine("get_hr=0x"+hg.ToString("X8")+" current="+v+" default="+def);}}}catch(Exception ex){Console.WriteLine(ex.GetType().Name+": "+ex.Message);}Marshal.ReleaseComObject(filter);}
 Marshal.ReleaseComObject(bag);Marshal.ReleaseComObject(arr[0]);}
 Marshal.ReleaseComObject(en);Marshal.ReleaseComObject(o);
 }
}
"@
[CameraQuery]::Run()
