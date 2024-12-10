/*
 * FILE          : startPage.aspx.cs
 * PROJECT       : Web Design and Development Assignment 6
 * PROGRAMMER    : Bilal Syed
 * FIRST VERSION : 2024-12-04
 * DESCRIPTION   : This file contains the server sideded for the text editor web application's start page, including methods
 *                 to retrieve directory contents, get file contents, and save file contents with various checks and validation.
 */

using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.Services;
using System.IO;
using System.Diagnostics;
using Newtonsoft.Json;

namespace WDD_A6
{
    public partial class startPage : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            
        }

        /*
         * METHOD      : DirectoryContents()
         * DESCRIPTION : Retrieves the list of all file names in the "MyFiles" directory and returns them as a JSON string.
         * PARAMETERS  : None
         * RETURNS     : A JSON string containing the file names in the "MyFiles" directory.
         */
        [WebMethod]
        public static string DirectoryContents()
        {
            string directory = HttpContext.Current.Server.MapPath("MyFiles");

            string[] files = Directory.GetFiles(directory);

            for (int i = 0; i < files.Length; i++)
            {
                files[i] = Path.GetFileName(files[i]);
            }

            return JsonConvert.SerializeObject(new { fileNames = files });
        }

        /*
         * METHOD      : GetFileContents()
         * DESCRIPTION : Reads the contents of a specified file from the "MyFiles" directory if it exists and returns the contents.
         * PARAMETERS  :
         *    - string fileName : The name of the file to retrieve the contents from.
         * RETURNS     : A JSON string containing the file contents if the file exits and an emptry string if it doesn't exist.
         */
        [WebMethod]
        public static string GetFileContents(string fileName)
        {
            string path = HttpContext.Current.Server.MapPath("MyFiles/" + fileName);

            string fileContents = string.Empty;

            if (File.Exists(path))
            {
                fileContents = File.ReadAllText(path);
                fileContents = JsonConvert.SerializeObject(new { contents = fileContents });
            }

            return fileContents;
        }

        /*
         * METHOD      : SaveFileContentsToCurrent()
         * DESCRIPTION : Saves the provided content to an existing file in the "MyFiles" directory.
         * PARAMETERS  :
         *    - string fileName     : The name of the file to save the contents to.
         *    - string fileContents : The content to be saved in the file.
         * RETURNS     : A JSON string indicating the success of the operation.
         */
        [WebMethod]
        public static string SaveFileContentsToCurrent(string fileName, string fileContents)
        {
            string path = HttpContext.Current.Server.MapPath("MyFiles/" + fileName);

            if (File.Exists(path))
            {
                File.WriteAllText(path, fileContents);
            }

            return JsonConvert.SerializeObject(new { status = "The edit space contents have been saved to the file " + fileName + "!" });
        }

        /*
         * METHOD      : SaveFileContentsAs()
         * DESCRIPTION : Saves the provided content as a new file in the "MyFiles" directory with validation for the file name,
         *               extension, and duplication. If the file name is invalid or if the extension is not allowed, an appropriate
         *               error is returned.
         * PARAMETERS  :
         *    - string fileName     : The name of the new file to create and save the contents to.
         *    - string fileContents : The content to be saved in the new file.
         * RETURNS     : A JSON string indicating the success of the operation or the type of error encountered. It will also return
         *               the file name when the operation is successful or when a file with the provided name already exists.
         */
        [WebMethod]
        public static string SaveFileContentsAs(string fileName, string fileContents)
        {
            string path = HttpContext.Current.Server.MapPath("MyFiles/" + fileName);
            char[] disallowedChars = Path.GetInvalidFileNameChars();
            string[] invalidExtensions = new string[]
            {
                ".exe", ".EXE", ".dll", ".DLL", ".msi", ".MSI", ".bat", ".BAT", ".bin", ".BIN", ".so", ".SO", ".o", ".O", ".elf", ".ELF",
                ".sys", ".SYS", ".drv", ".DRV", ".efi", ".EFI", ".zip", ".ZIP", ".rar", ".RAR", ".7z", ".7Z", ".gz", ".GZ", ".bz2", ".BZ2",
                ".xz", ".XZ", ".iso", ".ISO", ".img", ".IMG", ".vdi", ".VDI", ".vhd", ".VHD", ".dmg", ".DMG", ".bak", ".BAK", ".tar", ".TAR",
                ".cab", ".CAB", ".jpg", ".JPG", ".jpeg", ".JPEG", ".png", ".PNG", ".bmp", ".BMP", ".gif", ".GIF", ".tiff", ".TIFF", ".ico", ".ICO",
                ".svgz", ".SVGZ", ".ai", ".AI", ".eps", ".EPS", ".raw", ".RAW", ".cr2", ".CR2", ".nef", ".NEF", ".arw", ".ARW", ".orf", ".ORF", ".dng", ".DNG",
                ".mp3", ".MP3", ".aac", ".AAC", ".ogg", ".OGG", ".flac", ".FLAC", ".wma", ".WMA", ".wav", ".WAV", ".aiff", ".AIFF", ".mp4", ".MP4", ".avi", ".AVI",
                ".mov", ".MOV", ".mkv", ".MKV", ".flv", ".FLV", ".wmv", ".WMV", ".db", ".DB", ".sqlite", ".SQLITE", ".mdb", ".MDB", ".accdb", ".ACCDB", ".sqlitedb", ".SQLITEDB",
                ".xls", ".XLS", ".xlsx", ".XLSX", ".ods", ".ODS", ".dat", ".DAT", ".shp", ".SHP", ".gdb", ".GDB", ".kmz", ".KMZ", ".ttf", ".TTF", ".otf", ".OTF",
                ".woff", ".WOFF", ".woff2", ".WOFF2", ".class", ".CLASS", ".jar", ".JAR", ".pyc", ".PYC", ".obj", ".OBJ", ".wasm", ".WASM", ".cfg", ".CFG", ".ini", ".INI",
                ".pak", ".PAK", ".vpk", ".VPK", ".sav", ".SAV", ".stl", ".STL", ".fbx", ".FBX", ".3ds", ".3DS", ".dcm", ".DCM", ".dwg", ".DWG", ".dxf", ".DXF", ".step", ".STEP",
                ".enc", ".ENC", ".aes", ".AES", ".gpg", ".GPG", ".pfx", ".PFX", ".psd", ".PSD", ".indd", ".INDD", ".vmdk", ".VMDK", ".ova", ".OVA", ".hex", ".HEX", ".pdb", ".PDB",
                ".dmp", ".DMP", ".pst", ".PST", ".ost", ".OST", ".etl", ".ETL", ".swf", ".SWF"
            };
            string extension = Path.GetExtension(path);

            if (string.IsNullOrWhiteSpace(fileName))
            {
                return JsonConvert.SerializeObject(new { status = "failure" });
            }

            if (extension == string.Empty)
            {
                fileName += ".txt";
                path = HttpContext.Current.Server.MapPath("MyFiles/" + fileName);
            }
            else if (invalidExtensions.Contains(extension))
            {
                return JsonConvert.SerializeObject(new { status = "failure-invalid extension" });
            }

            if (File.Exists(path))
            {
                return JsonConvert.SerializeObject(new { status = "file exists", name = fileName });
            }

            for (int i = 0; i < disallowedChars.Length; i++)
            {
                if (fileName.Contains(disallowedChars[i]))
                {
                    return JsonConvert.SerializeObject(new { status = "failure" });
                }
            }

            File.WriteAllText(path, fileContents);

            return JsonConvert.SerializeObject(new { status = "success", name = fileName });
        }
    }
}