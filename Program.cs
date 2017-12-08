using System;
using System.Xml;

class SFCC {
    static void Main (string[] args) {
        // load master catalog
        XmlDocument docMasterCatalog = new XmlDocument ();
        docMasterCatalog.Load ("rkb_ashley_master_20171020.xml");
        XmlNamespaceManager ns1 = new XmlNamespaceManager (docMasterCatalog.NameTable);
        ns1.AddNamespace ("dw", "http://www.demandware.com/xml/impex/catalog/2006-10-31");

        // load site catalog
        XmlDocument docSiteCatalog = new XmlDocument ();
        docSiteCatalog.Load ("rkb_ashley_site_20171020.xml");
        XmlNamespaceManager ns2 = new XmlNamespaceManager (docSiteCatalog.NameTable);
        ns2.AddNamespace ("dw", "http://www.demandware.com/xml/impex/catalog/2006-10-31");

        Dictionary<string, VariantData> dictVariantData = new Dictionary<string, VariantData> ();

        StreamWriter swOutputVariants = new StreamWriter ("variants.txt");
        StreamWriter swOutputCatalogXML = new StreamWriter ("variants.xml");

        foreach (XmlNode nodeProduct in docMasterCatalog.SelectNodes ("//dw:catalog/dw:product", ns1)) {
            XmlNodeList nodeVariants = nodeProduct.SelectNodes ("dw:variations/dw:variants/dw:variant", ns1);
            if (nodeVariants != null && nodeVariants.Count > 0) {
                string masterID = nodeProduct.Attributes["product-id"].InnerText;

                foreach (XmlElement v in nodeVariants) {
                    string variantID = v.GetAttribute ("product-id");
                    VariantData d = new VariantData ();
                    d.masterID = masterID;
                    d.name = nodeProduct.SelectSingleNode ("dw:display-name", ns1).InnerText;

                    XmlNode nodeComponentProduct = docMasterCatalog.SelectSingleNode ("dw:catalog/dw:product[@product-id=\"" + variantID + "\"]", ns1);
                    if (nodeComponentProduct != null) {
                        var xColor = nodeComponentProduct.SelectSingleNode ("dw:custom-attributes/dw:custom-attribute[@attribute-id=\"color\"]", ns1);
                        d.color = xColor != null ? xColor.InnerText : string.Empty;
                        var xSize = nodeComponentProduct.SelectSingleNode ("dw:custom-attributes/dw:custom-attribute[@attribute-id=\"size2\"]", ns1);
                        d.size2 = xSize != null ? xSize.InnerText : string.Empty;
                    } else {
                        int a = 1;
                    }

                    string output = variantID + "\t" + d.masterID + "\t" + d.name + "\t" + d.color + "\t" + d.size2 + "\t";

                    d.categoryAssignments = new List<string> ();
                    XmlNodeList nodeCategoryAssignments = docSiteCatalog.SelectNodes ("//dw:catalog/dw:category-assignment[@product-id=\"" + variantID + "\"]", ns2);
                    foreach (XmlNode nodeCategoryAssignment in nodeCategoryAssignments) {
                        d.categoryAssignments.Add (nodeCategoryAssignment.Attributes["category-id"].InnerText);
                        output += nodeCategoryAssignment.Attributes["category-id"].InnerText + "\t";
                        swOutputCatalogXML.WriteLine ("<category-assignment category-id=\"" + nodeCategoryAssignment.Attributes["category-id"].InnerText + "\" product-id=\"" + variantID + "\" />");
                    }

                    dictVariantData.Add (variantID, d);

                    swOutputVariants.WriteLine (output);
                }
            }
        }

        swOutputVariants.Flush ();
        swOutputVariants.Close ();
        swOutputCatalogXML.Flush ();
        swOutputCatalogXML.Close ();

    }
}