using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Text;
using System.Xml.Serialization;

namespace PetClinic.DataProcessor.Dto.Import
{
    [XmlType("Procedure")]
    public class ProcedureDto
    {
        [Required]
        [XmlElement("Vet")]
        public string Vet { get; set; }

        [Required]
        [XmlElement("Animal")]
        public string AnimalPassportNumber { get; set; }

        [Required]
        [XmlElement("DateTime")]
        public string DateTime { get; set; }

        [XmlArray("AnimalAids")]
        public AnimalAidProceduresDto[] AnimalAids { get; set; }
    }
}
