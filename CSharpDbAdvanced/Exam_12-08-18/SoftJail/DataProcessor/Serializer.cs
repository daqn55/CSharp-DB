namespace SoftJail.DataProcessor
{

    using Data;
    using Newtonsoft.Json;
    using SoftJail.DataProcessor.ExportDto;
    using System;
    using System.Globalization;
    using System.IO;
    using System.Linq;
    using System.Text;
    using System.Xml;
    using System.Xml.Serialization;

    public class Serializer
    {
        public static string ExportPrisonersByCells(SoftJailDbContext context, int[] ids)
        {
            var prisoners = context.Prisoners.Where(x => ids.Any(i => x.Id == i))
                                             .ToArray()
                                             .Select(x => new
                                             {
                                                 x.Id,
                                                 Name = x.FullName,
                                                 CellNumber = x.Cell.CellNumber,
                                                 Officers = x.PrisonerOfficers.Select(o => new
                                                 {
                                                     OfficerName = o.Officer.FullName,
                                                     Department = o.Officer.Department.Name
                                                 })
                                                 .OrderBy(o => o.OfficerName)
                                                 .ToArray(),
                                                 TotalOfficerSalary = x.PrisonerOfficers.Sum(s => s.Officer.Salary)
                                             })
                                             .OrderBy(x => x.Name)
                                             .ThenBy(x => x.Id)
                                             .ToArray();

            var json = JsonConvert.SerializeObject(prisoners, Newtonsoft.Json.Formatting.Indented);

            return json;
        }

        public static string ExportPrisonersInbox(SoftJailDbContext context, string prisonersNames)
        {
            var names = prisonersNames.Split(',');

            var prisoners = context.Prisoners.Where(x => names.Any(n => x.FullName == n))
                                             .Select(x => new PrisonerExportDto
                                             {
                                                 Id = x.Id,
                                                 Name = x.FullName,
                                                 IncarcerationDate = x.IncarcerationDate.ToString("yyyy-MM-dd"),
                                                 EncryptedMessages = x.Mails.Select(m => new MailExportDto
                                                 {
                                                     Description = m.Description
                                                 })
                                                 .ToArray()
                                             })
                                             .OrderBy(x => x.Name)
                                             .ThenBy(x => x.Id)
                                             .ToArray();

            foreach (var p in prisoners)
            {
                foreach (var m in p.EncryptedMessages)
                {
                    var reverseDescription = string.Join("", m.Description.Reverse().ToArray());

                    m.Description = reverseDescription;
                }
            }

            var sb = new StringBuilder();

            var xmlNameSpaces = new XmlSerializerNamespaces(new[] { XmlQualifiedName.Empty });
            var xml = new XmlSerializer(typeof(PrisonerExportDto[]), new XmlRootAttribute("Prisoners"));
            xml.Serialize(new StringWriter(sb), prisoners, xmlNameSpaces);

            return sb.ToString();
        }
    }
}