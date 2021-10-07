using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Xml.Linq;

/// <summary>
/// This is used to compare site preference values based on the values configured for different instances. It's useful for making sure all the 
/// Staging values have been set for Production before a release (or similar for Development). Comment or uncomment the relevant sections based on 
/// what you want to know.
/// 
/// Compiling to executable
/// ----------------------
/// Compile this to a SFCCXMLSitePrefCompare.exe with:
/// PS C:\> csc SFCCXMLSitePrefCompare.cs
/// https://msdn.microsoft.com/en-us/library/78f4aasd(v=vs.100).aspx
/// 
/// Executing
/// ---------------------
/// PS C:\> .\SFCCXMLSitePrefCompare.exe [your xml file]
/// PS C:\> .\SFCCXMLSitePrefCompare.exe preferences.xml
/// </summary>
class Program {

    static XNamespace ns = "http://www.demandware.com/xml/impex/preferences/2007-03-31";

    static void Main(string[] args) {
        string targetInstance = "production";
        foreach (var item in args) {
            if (item.StartsWith("-")) {
                targetInstance = item.Substring(1);
            }
        }
        Console.WriteLine("Pref\tStaging Val\tProduction Val");
        new List<string> { "custom-preferences", "system-preferences" }.ForEach(type => {
            var xDocs = from f in args.Where(fname=>!fname.StartsWith("-"))
            select new {
                Name = new FileInfo(f).Name
                , Doc = XDocument.Load(f)
            };
            var prefs = xDocs.SelectMany(d => d.Doc.Descendants(ns + type)).ToArray();
            var ids = prefs.Descendants(ns + "preference").Attributes("preference-id").Select(att => att.Value).Distinct();

            foreach (var id in ids) {
                var vals = (
                    from d in xDocs
                    let customPrefs = d.Doc.Root.Descendants(ns + type).First()
                    //let devVal = customPrefs.Element(ns + "development")
                    //                    .Elements(ns + "preference")
                    //                    .Where(ele => ele.Attribute("preference-id").Value == id)
                    //                    .Select(ele => ele.Value)
                    let stagingVal = customPrefs.Element(ns + "staging")
                                        .Elements(ns + "preference")
                                        .Where(ele => ele.Attribute("preference-id").Value == id)
                                        .Select(ele => ele.Value)
                    let prodVal = customPrefs.Element(ns + "production")
                                        .Elements(ns + "preference")
                                        .Where(ele => ele.Attribute("preference-id").Value == id)
                                        .Select(ele => ele.Value)
                    //let val = customPrefs.Element(ns + targetInstance)
                    //                    .Elements(ns + "preference")
                    //                    .Where(ele => ele.Attribute("preference-id").Value == id)
                    //                    .Select(ele => ele.Value)
                    select new {
                        FileName = d.Name
                        , Preference = id
                        , StagingValue = stagingVal.FirstOrDefault()
                        , ProductionValue = prodVal.FirstOrDefault()
                    }
                );
                //if (vals.Select(v => v.Development).Distinct().Count() != 1) {
                //    Console.WriteLine();
                //    Console.WriteLine("Dev Values for {0} differ:", id);
                //    foreach (var valSet in vals) {
                //        Console.WriteLine("File {0} has {1}", valSet.FileName, valSet.Development);
                //    }
                //}
                //if (vals.Select(v => v.Staging).Distinct().Count() != 1) {
                //    Console.WriteLine();
                //    Console.WriteLine("Staging Values for {0} differ:", id);
                //    foreach (var valSet in vals) {
                //        Console.WriteLine("File {0} has {1}", valSet.FileName, valSet.Staging);
                //    }
                //}
                //if (vals.Select(v => v.Value).Distinct().Count() != 1) {
                //    Console.WriteLine();
                //    Console.WriteLine("{0} {1} for {2} differ:", targetInstance, type, id);
                //    foreach (var valSet in vals) {
                //        Console.WriteLine("{0}:\t{1}", valSet.FileName, valSet.Value);
                //    }
                //}
                if (vals.Where(v=>v.StagingValue != v.ProductionValue).Any()) {
                    var item = vals.First();
                    var stgval = "";
                    var prodval = "";
                    if(!String.IsNullOrEmpty(item.StagingValue)) {
                        stgval = item.StagingValue.Replace("\n", " ");
                        stgval = stgval.Replace("\t", " ");
                    }
                    if(!String.IsNullOrEmpty(item.ProductionValue)) {
                        prodval = item.ProductionValue.Replace("\n"," ");
                        prodval = prodval.Replace("\t"," ");
                    }
                    // Console.WriteLine("{0}\t{1}\t{2}",item.Preference, item.StagingValue.Replace(System.Environment.NewLine," "), item.ProductionValue.Replace(System.Environment.NewLine, " "));
                    Console.WriteLine("{0}\t{1}\t{2}",item.Preference, stgval, prodval);
                }
            }
        });
        
    }
}
