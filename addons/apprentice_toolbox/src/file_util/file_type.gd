#============================================================
#    File Type
#============================================================
# - author: zhangxuetu
# - datetime: 2024-04-23 21:45:42
# - version: 4.3.0.dev5
#============================================================
## 文件类型工具类 
##
## 根据文件头十六进制值来判断文件的类型
##[br][br]参考：[url=https://www.cnblogs.com/senior-engineer/p/9541719.html]利用文件头标志判断文件类型 [/url]
class_name FileType


const MAP = {
	"89504E": "png", #   
	"89504E47": "png", #   
	"89504E470D0A": "png", # PNG Image File 
	"89504E470D0A1A0A": "png", # PNG Image File 
	"FFD8FF": "jpg; jpeg", #   
	"FFD8FFE000": "jpg; jpe; jpeg", # JPG Graphic File 
	"FFD8FFFE00": "jpg; jpe; jpeg", # JPG Graphic File 
	"424D": "bmp", # Windows Bitmap 
	#"424D": "dib", # device-independent bitmap image 
	"424D3E": "bmp", #   
	"0000010000": "ico", # Icon File 
	"0000010001002020": "ico", # Icon File 
	"464F524D": "iff", #   
	"000100080001000101": "img", # Ventura Publisher/GEM VDI Image Format Bitmap file 
	"00FFFF": "img", #   
	"384250": "psd", #   
	"38425053": "psd", # Adobe Photoshop image file 
	"7E424B00": "psp", # PaintShop Pro Image File 
	"492049": "tif; tiff", # Tagged Image File Format file 
	"49492A": "tif; tiff", # TIFF (Intel) 
	"49492A00": "tif; tiff", # Tagged Image File Format file (little endian, i.e., LSB first in the byte; Intel) 
	"4D4D002A": "tif; TIFF", # Tagged Image File Format file (big endian, i.e., LSB last in the byte; Motorola) 
	"4D4D2A": "tif; tiff", # TIFF (Motorola) 
	"4D4D002B": "tif; tiff", # BigTIFF files; Tagged Image File Format files >4 GB 
	
	
	"00001A00051004": "123", # Lotus 1-2-3 spreadsheet (v9) file 
	"000000nn66747970336770": "3gg; 3gp; 3g2", # 3rd Generation Partnership Project 3GPP (nn=0x14) and 3GPP2 (nn=0x20) multimedia files 
	"377ABCAF271C": "7z", # 7-ZIP compressed file 
	"00014241": "aba", # Palm Address Book Archive file 
	"414F4C494E444558": "abi", # AOL address book index file 
	"414F4C4442": "aby; idx", # AOL database files: address book (ABY) and user configuration data (MAIN.IDX) 
	"000100005374616E6461726420414345204442": "accdb", # Microsoft Access 2007 file 
	"4D5A": "acm", # MS audio compression manager driver 
	#"4D5A": "vbx", # VisualBASIC application 
	#"4D5A": "vxd, 386", # Windows virtual device drivers 
	#"4D5A": "scr", # Screen saver 
	#"4D5A": "ocx", # ActiveX or OLE Custom Control 
	#"4D5A": "olb", # OLE object library 
	#"4D5A": "fon", # Font file 
	#"4D5A": "com, dll, drv, exe, pif, qts, qtx, sys", # Windows/DOS executable file 
	#"4D5A": "ax", # Library cache file 
	#"4D5A": "cpl", # Control panel application 
	#"4D5A": "exe; dll; drv; vxd; sys; ocx; vbx", # Win32 Executable 
	#"4D5A": "exe; dll; drv; vxd; sys; ocx; vbx", # Win16 Executable 
	#"4D5A": "exe; com; 386; ax; acm; sys; dll; drv; flt; fon; ocx; scr; lrc; vxd; cpl; x32", # Executable File 
	"4D5A90": "exe, dll, ocx, olb, imm, ime, dll", # Windows/DOS executable file
	#"4D5A90": "imm", #   
	#"4D5A90": "ime", #   
	#"4D5A90": "ocx", #   
	#"4D5A90": "olb", #   
	"444F53": "adf", # Amiga disk file 
	"0300000041505052": "adx", # Lotus Approach ADX file 
	"464F524D00": "aiff", # Audio Interchange File 
	"2112": "ain", # AIN Compressed Archive File 
	"5B7665725D": "ami", # Lotus Ami Pro 
	"2321414D52": "amr", # Adaptive Multi-Rate ACELP (Algebraic Code Excited Linear Prediction) Codec, commonly audio format with GSM cell phones 
	"52494646": "ani", #   
	"4D5A900003000000": "api", # Acrobat plug-in 
	#"4D5A900003000000": "flt", # Audition graphic filter file (Adobe) 
	#"4D5A900003000000": "ax", # DirectShow filter 
	"1A0x": "arc", # LH archive file, old version(where x = 0x2, 0x3, 0x4, 0x8 or 0x9 for types 1-5, respectively) 
	"41724301": "arc", # FreeArc compressed file 
	"60EA": "arj", # ARJ Compressed Archive 
	"60EA27": "arj", #   
	"4A47030E000000": "art", # AOL ART file 
	"4A47040E000000": "art", # AOL ART file 
	"3026B2758E66CF11": "asf", # Windows Media 
	"3026B2758E66CF11A6D900AA0062CE6C": "asf; wma; wmv", # Microsoft Windows Media Audio/Video File(Advanced Streaming Format) 
	"3C": "asx", # Advanced Stream redirector file 
	"2E736E64": "au", # SoundMachine Audio File NeXT/Sun Microsystems μ-Law audio file 
	"41564920": "avi", # Audio Video Interleave (AVI) 
	"414F4C2046656564626167": "bag", # AOL and AIM buddy list file 
	"202020": "bas", #   
	"424C4932323351": "bin", # Thomson Speedtouch series WLAN router firmware 
	"425A68": "bz; bz2", # BZIP Archive 
	#"425A68": "bz2; tar.bz2; tbz2; tb2", # bzip2 compressed archive 
	"495363": "cab", #   
	"49536328": "cab; hdr", # Install Shield v5.x or 6.x compressed file 
	"4D534346": "cab", # Microsoft CAB File Format 
	#"4D534346": "snp", # Microsoft Access Snapshot Viewer file 
	#"4D534346": "ppz", # Powerpoint Packaged Presentation 
	"30": "cat", # Microsoft security catalog file 
	"434246494C45": "cbd", # WordPerfect dictionary file (unconfirmed) 
	"5B436C": "ccd", #   
	"CDR": "cdr", # Corel Draw 
	"454C49544520436F6D6D616E64657220": "cdr", # Elite Plus Commander saved game file 
	"4D535F564F494345": "cdr, dvf", # Sony Compressed Voice File 
	#"4D535F564F494345": "msv", # Sony Memory Stick Compressed Voice file 
	"49545346": "chi; chm", # Microsoft Compiled HTML Help File 
	"495453": "chm", #   
	"434D5831": "clb", # Corel Binary metafile 
	"434F4D2B": "clb", # COM+ Catalog file 
	"3A42617365": "cnt", #   
	"4D5AEE": "com", #   
	"E93B03": "com", #   
	"464158434F5645522D564552": "cpe", # Microsoft Fax Cover Sheet 
	"4350543746494C45": "cpt", # Corel Photopaint file 
	"43505446494C45": "cpt", # Corel Photopaint file 
	"5B5769": "cpx", #   
	"4352555348": "cru; crush", # CRUSH Archive File 
	"43525553482076": "cru", # Crush compressed archive 
	"49491A00000048454150434344520200": "crw", # Canon digital camera RAW file 
	"436174616C6F6720332E303000": "ctf", # WhereIsIt Catalog file 
	"0000020001002020": "cur", # Windows cursor file 
	"1A52545320434F4D5052455353454420494D4147452056312E301A": "dat", # Runtime Software disk image 
	"415647365F496E746567726974795F4461746162617365": "dat", # AVG6 Integrity database file 
	"43524547": "dat", # Windows 9x registry hive 
	"436C69656E742055726C4361636865204D4D462056657220": "dat", # IE History DAT file 
	"45524653534156454441544146494C45": "dat", # Kroll EasyRecovery Saved Recovery State file 
	"496E6E6F20536574757020556E696E7374616C6C204C6F6720286229": "dat", # Inno Setup Uninstall Log file 
	"0006156100000002000004D200001000": "db", # Netscape Navigator (v4) database file 
	"44424648": "db", # Palm Zire photo database 
	#"03": "dat", # MapInfo Native Data Format 
	#"03": "db3", # dBASE III file 
	#"08": "db", # dBASE IV or dBFast configuration file 
	#"04": "db4", # dBASE IV data file 
	"00014244": "dba", # Palm DateBook Archive file 
	"CFAD12FE": "dbx", #   
	"CFAD12FEC5FD746F": "dbx", # Outlook Express 
	"3C21646F63747970": "dci", # AOL HTML mail file 
	"3ADE68B1": "dcx", # DCX Graphic File 
	"000100": "ddb", #   
	#"000100": "tst", #   
	#"000100": "ttf", #   
	"4D444D5093A7": "dmp", # Windows minidump file 
	#"4D444D5093A7": "hdmp", # Windows heap dump file 
	"444D5321": "dms", # Amiga DiskMasher compressed archive 
	"0D444F43": "doc", # DeskMate Document file 
	"1234567890FF": "doc", # MS Word 6.0 
	"31BE000000AB0000": "doc", # MS Word for DOS 6.0 
	"7FFE340A": "doc", # MS Word 
	"D0CF11E0": "dot; ppt; xla; ppa; pps; pot; msi; sdw; db", # MS Office/OLE2 
	"D0CF11E0A1B11AE1": "doc; dot; xls; xlt; xla; ppt; apr ;ppa; pps; pot; msi; sdw; db", # MS Compound Document v1 or Lotus Approach APR file 
	"4D5A50": "dpl", #   
	"4D5A16": "drv", #   
	"07": "drw", # A common signature and file extension for many drawing programs. 
	"01FF02040302": "drw", # Micrografx vector graphic file 
	"4D47582069747064": "ds4", # Micrografix Designer 4 
	"4D56": "dsn", # CD Stomper Pro label file 
	"23204D6963726F736F667420446576656C6F7065722053747564696F": "dsp", # Microsoft Developer Studio project file 
	"02647373": "dss", # Digital Speech Standard (Olympus, Grundig, & Phillips) 
	"0764743264647464": "dtd", # DesignTools 2D Design file 
	"3C21454E54495459": "dtd", # XML DTD 
	"445644": "dvr", # DVR-Studio stream file 
	#"445644": "ifo", # DVD info file 
	"414331": "dwg", #   
	"455646": "enn", # EnCase evidence file  (where nn are numbers)
	"2A5052": "eco", #   
	"7F454C4601010100": "elf", # ELF Executable 
	"0100000058000000": "emf", # Extended (Enhanced) Windows Metafile Format, printer spool file 
	"44656C69766572792D646174653A": "eml", # Email 
	"46726F6D202020": "eml", # A commmon file extension for e-mail files. Signatures shown here are for Netscape, Eudora, and a generic signature, respectively. EML is also used by Outlook Express and QuickMail. 
	"46726F6D203F3F3F": "eml", # A commmon file extension for e-mail files. Signatures shown here are for Netscape, Eudora, and a generic signature, respectively. EML is also used by Outlook Express and QuickMail. 
	"46726F6D3A20": "eml", # A commmon file extension for e-mail files. Signatures shown here are for Netscape, Eudora, and a generic signature, respectively. EML is also used by Outlook Express and QuickMail. 
	"526563": "eml", #   
	#"526563": "ppc", #   
	"005C41B1FF": "enc", # Mujahideen Secrets 2 encrypted file 
	"40404020000040404040": "enl", # EndNote Library File 
	"25215053": "eps", # Adobe EPS File 
	"252150532D41646F6265": "eps", # Postscript 
	#"252150532D41646F6265": "ps", # Postscript 
	"252150532D41646F62652D332E3020455053462D332030": "eps", # Adobe encapsulated PostScript file (If this signature is not at the immediate beginning of the file, it will occur early in the file, commonly at byte offset 30) 
	"C5D0D3": "eps", #   
	"1A350100": "eth", # GN Nettest WinPharoah capture file 
	"300000004C664C65": "evt", # Windows Event Viewer file 
	"03000000C466C456": "evt", #   
	"456C6646696C6500": "evtx", # Windows Vista event log file 
	"0011AF": "fli", # FLIC Animation file 
	"000101": "flt", # OpenFlight 3D file 
	"464C5601": "flv", # Flash video file 
	"3C4D616B657246696C6520": "fm", # Adobe FrameMaker file 
	"00001A0007800100": "fm3", # Lotus 123 v3 FMT file 
	"20006800200": "fmt", # Lotus 123 v4 FMT file 
	"434841": "fnt", #   
	"87F53E": "gbc", #   
	"3F5F0300": "gid", # Windows Help Index File 
	#"3F5F0300": "lhp", # Windows Help File 
	#"3F5F0300": "hlp", # Windows Help file 
	"4C4E0200": "gid", # Windows Help index file 
	#"4C4E0200": "hlp", # Windows Help file 
	"47494638": "gif", #   
	"474946383761": "gif", # Graphics interchange format file (GIF 87A) 
	"474946383961": "gif", # Graphics interchange format file (GIF89A) 
	"7B5072": "gtd", #   
	"475832": "gx2", # Show Partner graphics file (not confirmed) 
	"1F8B": "gz; tar; tgz", # Gzip Archive File 
	"1F8B08": "gz; tgz", # GZ Compressed File 
	"91334846": "hap", # HAP Archive File 
	"233F52414449414E43450A": "hdr", # adiance High Dynamic Range image file 
	"3F5F03": "hlp", #   
	#"3F5F03": "lhp", #   
	"0000FFFFFFFF": "hlp", # Windows Help file 
	"28546869732066696C65": "hqx", # Macintosh BinHex 4 Compressed Archive 
	"28546869732066696C65206D75737420626520636F6E76657274656420776974682042696E48657820": "hqx", # Macintosh BinHex 4 Compressed Archive 
	"3C2144": "HTM", #   
	"3C21444F4354": "htm; html", # HyperText Markup Language 3 
	"3C48544D4C3E": "htm; html", # HyperText Markup Language 2 
	"3C68746D6C3E": "htm; html", # HyperText Markup Language 1 
	"68746D6C3E": "html", # HTML 
	#"00FFFF": "smd", #   
	#"00FFFF": "mdf", #   
	"414F4C494458": "ind", # AOL client preferences/settings file (MAIN.IND) 
	"4344303031": "iso", # ISO-9660 CD Disc Image (This signature usually occurs at byte 8001, 8801, or 9001.) 
	"2E524543": "ivr", # RealPlayer video file (V11 and later) 
	"4A4152435300": "jar", # JARCS compressed archive 
	"5F27A889": "jar", # JAR Archive File 
	"4B47425F61726368202D": "kgb", # KGB archive 
	"49443303000000": "koz", # Sprint Music Store audio file (for mobile devices) 
	"42494C": "ldb", #   
	"2D6C68352D": "lha", # LHA Compressed 
	"2D6C68": "lha; lzh", # Compressed archive file 
	"213C617263683E0A": "lib", # Unix archiver (ar) files and Microsoft Program Library Common Object File Format (COFF) 
	"2A2420": "lib", #   
	"49544F4C49544C53": "lit", # Microsoft Reader eBook file 
	"4C0000": "lnk", #   
	"4C000000": "lnk", # Windows Shortcut (Link File) 
	"4C000000011402": "lnk", # Windows Link File 
	"4C00000001140200": "lnk", # Windows shortcut file 
	"2A2A2A2020496E7374616C6C6174696F6E205374617274656420": "log", # Symantec Wise Installer log file 
	"lh": "lzh", # Lz compression file 
	"576F726450726F": "lwp", # Lotus WordPro v9 
	"234558": "m3u", #   
	"00000020667479704D34412000000000": "m4a", # Apple Lossless Audio Codec file 
	#"00000020667479704D34412000000000": "m4a; m4v", # QuickTime M4A/M4V file 
	"3C3F786D6C2076657273696F6E3D": "manifest", # Windows Visual Stylesheet XML file 
	"4D41523100": "mar", # Mozilla archive 
	"4D415243": "mar", # Microsoft/MSN MARC archive 
	"4D41723000": "mar", # MAr compressed archive 
	"D0CF11": "xls", #   
	#"D0CF11E0": "xls", # MS Excel 
	#"D0CF11": "max", #   
	#"D0CF11": "ppt", #   
	"000100005374616E64617264204A6574204442": "mdb", # Microsoft Access file 
	"5374616E64617264204A": "mdb; mda; mde; mdt", # MS Access 
	"00FFFFFFFFFFFFFFFFFFFF0000020001": "mdf", # Alcohol 120% CD image 
	"010F0000": "mdf", # Microsoft SQL Server 2000 database 
	"4550": "mdi", # Microsoft Document Imaging file 
	"4D4544": "mds", #   
	"4D546864": "mid; midi", # Musical Instrument Digital Interface (MIDI) sound file 
	"1A45DFA3934282886D6174726F736B61": "mkv", # Matroska stream file 
	"4D494C4553": "mls", # Milestones v1.0 project management and scheduling software (Also see “MV2C” and “MV214” signatures) 
	"4D4C5357": "mls", # Skype localization data file 
	"4D56323134": "mls", # Milestones v2.1b project management and scheduling software (Also see “MILES” and “MV2C” signatures) 
	"4D563243": "mls", # Milestones v2.1a project management and scheduling software (Also see “MILES” and “MV214” signatures) 
	"4D4D4D440000": "mmf", # Yamaha Corp. Synthetic music Mobile Application Format (SMAF) for multimedia files that can be played on hand-held devices. 
	"000100004D534953414D204461746162617365": "mny", # Microsoft Money file 
	"00000F": "mov", #   
	"000077": "mov", #   
	"6D6F6F76": "mov", # Quicktime 
	"6D646174": "mov", # QuickTime Movie 
	#"6D646174": "qt", # Quicktime Movie File 
	"0CED": "mp", # Monochrome Picture TIFF bitmap file (unconfirmed) 
	"494433": "mp3", # MPEG-1 Audio Layer 3 (MP3) audio file 
	"FFFB50": "mp3", #   
	"000000186674797033677035": "mp4", # MPEG-4 video files 
	"000001": "mpa", #   
	"000001B3": "mpg; mpeg", # MPEG Movie 
	"000001BA": "mpg", # MPEG 
	#"000001BA": "vob", # DVD Video Movie File (video/dvd, video/mpeg) 
	"3C3F78": "msc", #   
	#"3C3F78": "xml", #   
	#"3C3F786D6C2076657273696F6E3D22312E30223F3E0D0A3C4D4D435F436F6E736F6C6546696C6520436F6E736F6C6556657273696F6E3D22": "msc", # Microsoft Management Console Snap-in Control file 
	"2320": "msi", # Cerius2 file 
	"4E4553": "nes", #   
	"C22020": "nls", #   
	"0E4E65726F49534F": "nri", # Nero CD Compilation 
	"1A0000": "ntf", # Lotus Notes database template 
	"1A0000030000": "nsf; ntf", # Lotus Notes Database/Template 
	"1A00000300001100": "nsf", # Notes Database 
	"1A0000040000": "nsf", # Lotus Notes database 
	"30314F52444E414E43452053555256455920202020202020": "ntf", # National Transfer Format Map File 
	"4C01": "obj", # Microsoft Common Object File Format (COFF) relocatable object code file for an Intel 386 or later/compatible processors 
	"414F4C564D313030": "org; pfc", # AOL personal file cabinet (PFC) file 
	"1A0B": "pak", # Compressed archive file 
	"4746315041544348": "pat", # Advanced Gravis Ultrasound patch file 
	"47504154": "pat", # GIMP (GNU Image Manipulation Program) pattern file 
	"5B4144": "pbk", #   
	"17A150": "pcb", #   
	"0A0501": "pcs", #   
	"0Ann0101": "pcx", # ZSOFT Paintbrush file(where nn = 0x02, 0x03, or 0x05) 
	"0A050108": "pcx", # PC Paintbrush(often associated with Quake Engine games) 
	"000000000000000000000000000000000000000000000000": "pdb", # Palmpilot Database/Document File 
	"255044": "pdf", #   
	"25504446": "pdf; fdf", # Adobe Portable Document Format and Forms Document file 
	"255044462D312E": "pdf", # Adobe Acrobat 
	"484802": "pdg", #   
	"1100000053434341": "pf", # Windows prefetch file 
	"0100000001": "pic", # Unknown type picture file 
	"000007": "pjt", #   
	"24536F": "pll", #   
	"006E1EF0": "ppt", # PowerPoint presentation subheader (MS Office) 
	"0F00E803": "ppt", # PowerPoint presentation subheader (MS Office) 
	"424F4F4B4D4F4249": "prc", # Palmpilot resource file 
	"234445": "prg", #   
	"2142444E": "pst", # Microsoft Outlook Personal Folder file 
	"E3828596": "pwl", # Windows Password 
	"458600000600": "qbb", # Intuit QuickBooks Backup file 
	"AC9EBD8F": "qdf", # Quicken 
	"03000000": "qph", # Quicken price history file 
	"2E524D460000001200": "ra", # Real Audio file 
	"2E7261FD": "ra; ram", # Real Audio File 
	"2E7261FD00": "ra", # RealAudio streaming media file 
	"526172": "rar", #   
	"52617221": "rar", # RAR Archive File 
	"060500": "raw", #   
	"5245474544495434": "reg", #   
	"01DA01010003": "rgb", # Silicon Graphics RGB Bitmap 
	"2E524D": "rm", #   
	"2E524D46": "rm; rmvb", # Real Media streaming media file 
	"EDABEEDB": "rpm", # RPM Archive File 
	"43232B44A4434DA5486472": "rtd", # RagTime document file 
	"7B5C72": "rtf", #   
	"7B5C727466": "rtf", # Rich Text Format File 
	"24464C3240282329205350535320444154412046494C45": "sav", # SPSS Data file 
	"46454446": "sbv", # (Unknown file type) 
	"2A7665": "sch", #   
	"805343": "scm", #   
	"4848474231": "sh3", # Harvard Graphics presentation file 
	"4B490000": "shd", # Windows 9x printer spool file 
	"53495421": "sit", # Stuffit v1 Archive File 
	"53747566664974": "sit", # Stuffit v5 Archive File 
	"3A56455253494F4E": "sle", # Surfplan kite project file 
	"414376": "sle", # teganos Security Suite virtual secure drive 
	"53520100": "sly; srt; slt", # Sage sly.or.srt.or.slt 
	"001E849000000000": "snm", # Netscape Communicator (v4) mail folder 
	"00BF": "sol", # Adobe Flash shared object file (e.g., Flash cookies) 
	"00000100": "spl", # Windows NT/2000/XP printer spool file 
	"FFFFFF": "sub", #   
	"435753": "swf", # Shockwave Flash file (v5+) 
	"465753": "swf", # Macromedia Shockwave Flash player file 
	"414D594F": "syw", # Harvard Graphics symbol graphic 
	"000002": "tag", #   
	#"000002": "tga", #   
	"303730373037": "tar; cpio", # CPIO Archive File 
	"1F9D90": "tar.z", # Compressed tape archive file 
	"0000100000": "tga", # RLE压缩的前5字节 
	"0000020000": "tga", # 未压缩的前5字节 
	"4D53465402000100": "tlb", # OLE, SPSS, or Visual C++ type library file 
	"0110": "tr1", # Novell LANalyzer capture file 
	"554641": "ufa", # UFA Archive File 
	"454E5452595643440200000102001858": "vcd", # VideoVCD (GNU VCDImager) file 
	"424547494E3A56434152440D0A": "vcf", # vCard file 
	"524946": "wav", #   
	"57415645": "wav", # Wave 
	"57415645666D74": "wav", # Wave Files 
	"00000200": "wb2", # QuattroPro for Windows Spreadsheet file 
	"3E000300FEFF090006": "wb3", # Quatro Pro for Windows 7.0 Notebook file 
	"2000604060": "wk1; wks", # Lotus 123 v1 Worksheet 
	"0000020006040600080000000000": "wk1", # Lotus 1-2-3 spreadsheet (v1) file 
	"00001A0000100400": "wk3", # Lotus 123 spreadsheet (v3) file 
	"00001A0002100400": "wk4; wk5", # Lotus 1-2-3 spreadsheet (v4, v5) file 
	"0E574B53": "wks", # DeskMate Worksheet 
	"3026B2": "wmv", #   
	#"3026B2": "wma", #   
	"01000900": "wmf", # Graphics Metafile 
	"010009000003": "wmf", # Windows Metadata file (Win 3.x format) 
	"02000900": "wmf", # Graphics Metafile 
	"D7CDC69A": "wmf", # Windows Meta File 
	"FF575043": "wp", # WordPerfect v5 or v6 
	#"FF575043": "wpd", # WordPerfect 
	"FF575047": "wpg", # WordPerfect Graphics 
	"31BE": "wri", # Microsoft Write file 
	"31BE00": "wri", #   
	"32BE": "wri", # Microsoft Write file 
	"1D7D": "ws", # WordStar Version 5.0/6.0 document 
	"584245": "xbe", #   
	#"3C": "xdr", # BizTalk XML-Data Reduced Schema file 
	"0902060000001000B9045C00": "xls", # MS Excel v2 
	"0904060000001000F6055C00": "xls", # MS Excel v4 
	"0908100000060500": "xls", # Excel spreadsheet subheader (MS Office) 
	"3C3F786D6C": "xml", # XML Document 
	"FFFE3C0052004F004F0054005300540055004200": "xml", # XML Document (ROOTSTUB) 
	"005001": "xmv", #   
	"FFFE3C": "xsl", #   
	"7273696F6E3D22313C3F786D6C2076652E30223F3E": "xul", # XML User Interface Language file 
	"1F9D": "z", # TAR Compressed Archive File 
	"1F9D8C": "z", #   
	"504B03": "zip", #   
	"504B0304": "zip; jar; zipx", # ZIP Archive 
	"504B3030": "zip", # ZIP Archive (outdated) 
	"504B3030504B0304": "zip", # WINZIP Compressed 
	"5A4F4F20": "zoo", # ZOO Archive File 
}


## 获取文件类型
static func get_type(bytes: PackedByteArray) -> String:
	var hex = bytes.slice(0, 16).hex_encode().to_upper()
	if bytes.slice(0, 4).get_string_from_ascii().begins_with("RIFF"):
		return "webp"
	for key in MAP:
		if hex.begins_with(key):
			return MAP[key]
	return ""


## 是否是这种类型
static func is_type(bytes: PackedByteArray, type_name: String) -> bool:
	return get_type(bytes).contains(type_name)
