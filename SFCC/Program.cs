using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Xml;

// usage: dotnet run
// should create a few files, namely category assignments for variations, and all products classification and primary category assignment
// all paths are currently hardcoded

namespace SFCC
{
    class VariantData
    {
        public string name;
        public string masterID;
        public string color;
        public string size2;
        public List<string> categoryAssignments;
    }
    class Program
    {
        static void Main(string[] args)
        {
            if (Array.IndexOf(args, "-h") > -1 || Array.IndexOf(args, "--help") > -1)
            {
                System.Console.WriteLine("Catalog inspector - use this to parse site and master catalog xml and output lists of all primary and classification category assignment for products as well as details for all variation products including their master product, size, color and if they are assigned to a category");
                return;
            }

            string masterFile = "master-catalog.xml";
            string siteFile = "site-catalog.xml";

             if (Array.IndexOf(args, "-m") > -1)
            {
                if (args.Length > (Array.IndexOf(args, "-m") + 1))
                {
                    masterFile = args[Array.IndexOf(args, "-m") + 1];
                }
                else { System.Console.WriteLine("-m argument specified, but no file specified. defaulting to {0}", masterFile); }
            }
            if (Array.IndexOf(args, "-s") > -1)
            {
                if (args.Length > (Array.IndexOf(args, "-s") + 1))
                {
                    siteFile = args[Array.IndexOf(args, "-s") + 1];
                }
                else { System.Console.WriteLine("-s argument specified, but no file specified. defaulting to {0}", siteFile); }
            }
            System.Console.WriteLine("Reading from master catalog {0} and site catalog {1}", masterFile, siteFile);

            // load master catalog
            XmlDocument docMasterCatalog = new XmlDocument();
            docMasterCatalog.Load(masterFile);
            XmlNamespaceManager ns1 = new XmlNamespaceManager(docMasterCatalog.NameTable);
            ns1.AddNamespace("dw", "http://www.demandware.com/xml/impex/catalog/2006-10-31");

            // load site catalog
            XmlDocument docSiteCatalog = new XmlDocument();
            docSiteCatalog.Load(siteFile);
            XmlNamespaceManager ns2 = new XmlNamespaceManager(docSiteCatalog.NameTable);
            ns2.AddNamespace("dw", "http://www.demandware.com/xml/impex/catalog/2006-10-31");

            Dictionary<string, VariantData> dictVariantData = new Dictionary<string, VariantData>();

            StreamWriter swOutputVariants = new StreamWriter("variants.txt");
            StreamWriter swOutputCatalogXML = new StreamWriter("variants.xml");
            StreamWriter categoryAssignments = new StreamWriter("categoryAssignments.csv");
            categoryAssignments.WriteLine("productId,primaryCategory,classificationCategory");
            int standardProductCount = 0;
            int masterProductCount = 0;
            int variationProductCount = 0;

            Dictionary<string, string> productPrimaryCategories = new Dictionary<string, string>();
            XmlNodeList primaryFlags = docSiteCatalog.SelectNodes("//dw:catalog/dw:category-assignment/dw:primary-flag[text()=\"true\"]", ns2);
            foreach (XmlNode flag in primaryFlags)
            {
                Console.WriteLine(flag.ParentNode.Attributes["product-id"].InnerText + " " + flag.ParentNode.Attributes["category-id"].InnerText);
                productPrimaryCategories.Add(flag.ParentNode.Attributes["product-id"].InnerText, flag.ParentNode.Attributes["category-id"].InnerText);
            }

            foreach (XmlNode nodeProduct in docMasterCatalog.SelectNodes("//dw:catalog/dw:product", ns1))
            {
                categoryAssignments.Write(nodeProduct.Attributes["product-id"].InnerText + ",");
                if (productPrimaryCategories.ContainsKey(nodeProduct.Attributes["product-id"].InnerText))
                {
                    categoryAssignments.Write(productPrimaryCategories[nodeProduct.Attributes["product-id"].InnerText]);
                }
                categoryAssignments.Write(",");

                if (nodeProduct.SelectSingleNode("dw:classification-category", ns1) != null && nodeProduct.SelectSingleNode("dw:classification-category", ns1).InnerText.Length > 0)
                {
                    categoryAssignments.Write(nodeProduct.SelectSingleNode("dw:classification-category", ns1).InnerText);
                }
                categoryAssignments.WriteLine();


                XmlNodeList nodeVariants = nodeProduct.SelectNodes("dw:variations/dw:variants/dw:variant", ns1);
                if (nodeVariants != null && nodeVariants.Count > 0)
                {
                    masterProductCount++;
                    string masterID = nodeProduct.Attributes["product-id"].InnerText;

                    foreach (XmlElement v in nodeVariants)
                    {
                        variationProductCount++;
                        standardProductCount--;
                        string variantID = v.GetAttribute("product-id");
                        VariantData d = new VariantData();
                        d.masterID = masterID;
                        d.name = nodeProduct.SelectSingleNode("dw:display-name", ns1).InnerText;

                        XmlNode nodeComponentProduct = docMasterCatalog.SelectSingleNode("dw:catalog/dw:product[@product-id=\"" + variantID + "\"]", ns1);
                        if (nodeComponentProduct != null)
                        {
                            var xColor = nodeComponentProduct.SelectSingleNode("dw:custom-attributes/dw:custom-attribute[@attribute-id=\"color\"]", ns1);
                            d.color = xColor != null ? xColor.InnerText : string.Empty;
                            var xSize = nodeComponentProduct.SelectSingleNode("dw:custom-attributes/dw:custom-attribute[@attribute-id=\"size2\"]", ns1);
                            d.size2 = xSize != null ? xSize.InnerText : string.Empty;
                        }
                        string output = variantID + "\t" + d.masterID + "\t" + d.name + "\t" + d.color + "\t" + d.size2 + "\t";

                        d.categoryAssignments = new List<string>();
                        XmlNodeList nodeCategoryAssignments = docSiteCatalog.SelectNodes("//dw:catalog/dw:category-assignment[@product-id=\"" + variantID + "\"]", ns2);
                        foreach (XmlNode nodeCategoryAssignment in nodeCategoryAssignments)
                        {
                            d.categoryAssignments.Add(nodeCategoryAssignment.Attributes["category-id"].InnerText);
                            output += nodeCategoryAssignment.Attributes["category-id"].InnerText + "\t";
                            swOutputCatalogXML.WriteLine("<category-assignment category-id=\"" + nodeCategoryAssignment.Attributes["category-id"].InnerText + "\" product-id=\"" + variantID + "\" />");
                        }
                        dictVariantData.Add(variantID, d);
                        swOutputVariants.WriteLine(output);
                    }
                }
                else
                {
                    standardProductCount++;
                }
            }
            Console.WriteLine("Total products {0}, standard products: {1}, master products {2}, variation products {3}", docMasterCatalog.SelectNodes("//dw:catalog/dw:product", ns1).Count, standardProductCount, masterProductCount, variationProductCount);
            swOutputVariants.Flush();
            swOutputVariants.Close();
            swOutputCatalogXML.Flush();
            swOutputCatalogXML.Close();
            categoryAssignments.Flush();
            categoryAssignments.Close();
        }
    }
}