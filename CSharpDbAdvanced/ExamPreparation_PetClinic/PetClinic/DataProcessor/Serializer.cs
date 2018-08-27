namespace PetClinic.DataProcessor
{
    using System;
    using System.Globalization;
    using System.IO;
    using System.Linq;
    using System.Text;
    using System.Xml;
    using System.Xml.Serialization;
    using Newtonsoft.Json;
    using PetClinic.Data;
    using PetClinic.DataProcessor.Dto.Export;

    public class Serializer
    {
        public static string ExportAnimalsByOwnerPhoneNumber(PetClinicContext context, string phoneNumber)
        {
            var animals = context.Animals.Where(x => x.Passport.OwnerPhoneNumber == phoneNumber)
                                         .ToArray()
                                         .Select(x => new
                                         {
                                             OwnerName = x.Passport.OwnerName,
                                             AnimalName = x.Name,
                                             Age = x.Age,
                                             SerialNumber = x.Passport.SerialNumber,
                                             RegisteredOn = x.Passport.RegistrationDate.ToString("dd-MM-yyyy", CultureInfo.InvariantCulture)
                                         })
                                         .OrderBy(x => x.Age)
                                         .ThenBy(x => x.SerialNumber)
                                         .ToArray();

            var json = JsonConvert.SerializeObject(animals, Newtonsoft.Json.Formatting.Indented);

            return json;
        }

        public static string ExportAllProcedures(PetClinicContext context)
        {
            var procedures = context.Procedures
                                        .OrderBy(x => x.DateTime)
                                        .Select(x => new ProcedureExportDto
                                        {
                                            Passport = x.Animal.Passport.SerialNumber,
                                            OwnerNumber = x.Animal.Passport.OwnerPhoneNumber,
                                            DateTime = x.DateTime.ToString("dd-MM-yyyy", CultureInfo.InvariantCulture),
                                            AnimalAids = x.ProcedureAnimalAids.Select(a => new AnimalAidExportDto
                                            {
                                                Name = a.AnimalAid.Name,
                                                Price = a.AnimalAid.Price
                                            })
                                            .ToArray(),
                                            TotalPrice = x.Cost
                                        })
                                        .OrderBy(x => x.Passport)
                                        .ToArray();

            var sb = new StringBuilder();

            var xmlNameSpaces = new XmlSerializerNamespaces(new[] { XmlQualifiedName.Empty });
            var xml = new XmlSerializer(typeof(ProcedureExportDto[]), new XmlRootAttribute("Procedures"));
            xml.Serialize(new StringWriter(sb), procedures, xmlNameSpaces);

            return sb.ToString();
        }
    }
}
