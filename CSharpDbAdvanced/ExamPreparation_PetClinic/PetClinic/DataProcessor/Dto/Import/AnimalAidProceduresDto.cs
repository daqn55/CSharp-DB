using System.ComponentModel.DataAnnotations;
using System.Xml.Serialization;

namespace PetClinic.DataProcessor.Dto.Import
{
    [XmlType("AnimalAid")]
    public class AnimalAidProceduresDto
    {
        [Required]
        [XmlElement("Name")]
        public string Name { get; set; }
    }
}