namespace PetClinic.DataProcessor
{
    using System;
    using System.Collections.Generic;
    using System.ComponentModel.DataAnnotations;
    using System.Globalization;
    using System.IO;
    using System.Linq;
    using System.Text;
    using System.Xml.Serialization;
    using Newtonsoft.Json;
    using PetClinic.Data;
    using PetClinic.DataProcessor.Dto.Import;
    using PetClinic.Models;

    public class Deserializer
    {
        private const string errorMsg = "Error: Invalid data.";
        private const string successMsg = "Record {0} successfully imported.";
        private const string successMgsAnimal = "Record {0} Passport №: {1} successfully imported.";
        private const string successMgsPocedure = "Record successfully imported.";

        public static string ImportAnimalAids(PetClinicContext context, string jsonString)
        {
            var sb = new StringBuilder();

            var json = JsonConvert.DeserializeObject<AnimalAidDto[]>(jsonString);

            var animalAids = new List<AnimalAid>();
            foreach (var animalAidDto in json)
            {
                if (!IsValid(animalAidDto))
                {
                    sb.AppendLine(errorMsg);
                    continue;
                }

                if (animalAids.Any(x => x.Name == animalAidDto.Name))
                {
                    sb.AppendLine(errorMsg);
                    continue;
                }

                if (context.AnimalAids.Any(x => x.Name == animalAidDto.Name))
                {
                    sb.AppendLine(errorMsg);
                    continue;
                }

                AnimalAid animalAid = new AnimalAid
                {
                    Name = animalAidDto.Name,
                    Price = animalAidDto.Price
                };
                animalAids.Add(animalAid);

                sb.AppendLine(string.Format(successMsg, animalAid.Name));

            }
            context.AnimalAids.AddRange(animalAids);
            context.SaveChanges();

            return sb.ToString().TrimEnd();
        }

        public static string ImportAnimals(PetClinicContext context, string jsonString)
        {
            var sb = new StringBuilder();

            var json = JsonConvert.DeserializeObject<AnimalDto[]>(jsonString);

            List<Animal> animals = new List<Animal>();
            foreach (var animalDto in json)
            {
                if (!IsValid(animalDto))
                {
                    sb.AppendLine(errorMsg);
                    continue;
                }

                if (!IsValid(animalDto.Passport))
                {
                    sb.AppendLine(errorMsg);
                    continue;
                }

                if (animalDto.Passport.SerialNumber.Length < 10)
                {
                    sb.AppendLine(errorMsg);
                    continue;
                }

                var serialNumberIsValid = true;
                var sNumber = animalDto.Passport.SerialNumber;
                for (int i = 0; i < 10; i++)
                {
                    if (i <= 6)
                    {
                        if (!char.IsLetter(sNumber[i]))
                        {
                            serialNumberIsValid = false;
                            break;
                        }
                    }
                    else
                    {
                        if (!char.IsDigit(sNumber[i]))
                        {
                            serialNumberIsValid = false;
                            break;
                        }
                    }
                }

                if (!serialNumberIsValid)
                {
                    sb.AppendLine(errorMsg);
                    continue;
                }

                var phoneNumberIsValid = true;
                var phNumber = animalDto.Passport.OwnerPhoneNumber;
                if (phNumber.StartsWith("+359") && phNumber.Length == 13)
                {
                    for (int i = 4; i < 13; i++)
                    {
                        if (!char.IsDigit(phNumber[i]))
                        {
                            phoneNumberIsValid = false;
                            break;
                        }
                    }
                }
                else
                {
                    phoneNumberIsValid = false;
                }

                if (!phoneNumberIsValid)
                {
                    if (phNumber.StartsWith("0") && phNumber.Length == 10)
                    {
                        phoneNumberIsValid = true;

                        for (int i = 1; i < 10; i++)
                        {
                            if (!char.IsDigit(phNumber[i]))
                            {
                                phoneNumberIsValid = false;
                                break;
                            }
                        }
                    }
                    else
                    {
                        phoneNumberIsValid = false;
                    }
                }
                
                if (!phoneNumberIsValid)
                {
                    sb.AppendLine(errorMsg);
                    continue;
                }

                if (context.Passports.Any(x => x.SerialNumber == animalDto.Passport.SerialNumber))
                {
                    sb.AppendLine(errorMsg);
                    continue;
                }

                if (animals.Any(x => x.Passport.SerialNumber == animalDto.Passport.SerialNumber))
                {
                    sb.AppendLine(errorMsg);
                    continue;
                }

                var date = DateTime.ParseExact(animalDto.Passport.RegistrationDate, "dd-MM-yyyy", CultureInfo.InvariantCulture);

                Passport passport = new Passport
                {
                    SerialNumber = animalDto.Passport.SerialNumber,
                    OwnerName = animalDto.Passport.OwnerName,
                    OwnerPhoneNumber = animalDto.Passport.OwnerPhoneNumber,
                    RegistrationDate = date
                };

                Animal animal = new Animal
                {
                    Name = animalDto.Name,
                    Type = animalDto.Type,
                    Age = animalDto.Age,
                    Passport = passport
                };

                animals.Add(animal);

                sb.AppendLine(string.Format(successMgsAnimal, animal.Name, animal.Passport.SerialNumber));
            }

            context.Animals.AddRange(animals);
            context.SaveChanges();

            return sb.ToString().TrimEnd();
        }

        public static string ImportVets(PetClinicContext context, string xmlString)
        {
            var sb = new StringBuilder();

            var xml = new XmlSerializer(typeof(VetDto[]), new XmlRootAttribute("Vets"));
            var deserializerVets = (VetDto[])xml.Deserialize(new StringReader(xmlString));

            List<Vet> vets = new List<Vet>();
            foreach (var vetDto in deserializerVets)
            {
                if (!IsValid(vetDto))
                {
                    sb.AppendLine(errorMsg);
                    continue;
                }

                var phoneNumberIsValid = true;
                var phNumber = vetDto.PhoneNumber;
                if (phNumber.StartsWith("+359") && phNumber.Length == 13)
                {
                    for (int i = 4; i < 13; i++)
                    {
                        if (!char.IsDigit(phNumber[i]))
                        {
                            phoneNumberIsValid = false;
                            break;
                        }
                    }
                }
                else
                {
                    phoneNumberIsValid = false;
                }

                if (!phoneNumberIsValid)
                {
                    if (phNumber.StartsWith("0") && phNumber.Length == 10)
                    {
                        phoneNumberIsValid = true;

                        for (int i = 1; i < 10; i++)
                        {
                            if (!char.IsDigit(phNumber[i]))
                            {
                                phoneNumberIsValid = false;
                                break;
                            }
                        }
                    }
                    else
                    {
                        phoneNumberIsValid = false;
                    }
                }

                if (!phoneNumberIsValid)
                {
                    sb.AppendLine(errorMsg);
                    continue;
                }

                if (vets.Any(x => x.PhoneNumber == vetDto.PhoneNumber))
                {
                    sb.AppendLine(errorMsg);
                    continue;
                }

                if (context.Vets.Any(x => x.PhoneNumber == vetDto.PhoneNumber))
                {
                    sb.AppendLine(errorMsg);
                    continue;
                }

                Vet vet = new Vet
                {
                    Name = vetDto.Name,
                    Profession = vetDto.Profession,
                    Age = vetDto.Age,
                    PhoneNumber = vetDto.PhoneNumber
                };

                vets.Add(vet);
                sb.AppendLine(string.Format(successMsg, vetDto.Name));
            }

            context.Vets.AddRange(vets);
            context.SaveChanges();

            return sb.ToString().TrimEnd();
        }

        public static string ImportProcedures(PetClinicContext context, string xmlString)
        {
            var sb = new StringBuilder();

            var xml = new XmlSerializer(typeof(ProcedureDto[]), new XmlRootAttribute("Procedures"));
            var deserializerVets = (ProcedureDto[])xml.Deserialize(new StringReader(xmlString));

            List<ProcedureAnimalAid> procedureAnimalAids = new List<ProcedureAnimalAid>();
            foreach (var procedureDto in deserializerVets)
            {
                List<AnimalAid> animalAids = new List<AnimalAid>();
                bool validAnimalAid = true;

                if (!IsValid(procedureDto))
                {
                    sb.AppendLine(errorMsg);
                    continue;
                }

                var vet = context.Vets.FirstOrDefault(x => x.Name == procedureDto.Vet);
                if (vet == null)
                {
                    sb.AppendLine(errorMsg);
                    continue;
                }

                var animal = context.Animals.FirstOrDefault(x => x.Passport.SerialNumber == procedureDto.AnimalPassportNumber);
                if (animal == null)
                {
                    sb.AppendLine(errorMsg);
                    continue;
                }

                var date = DateTime.ParseExact(procedureDto.DateTime, "dd-MM-yyyy", CultureInfo.InvariantCulture);

                foreach (var animalAidProcDto in procedureDto.AnimalAids)
                {
                    if (!IsValid(animalAidProcDto))
                    {
                        validAnimalAid = false;
                        break;
                    }

                    if (animalAids.Any(x => x.Name == animalAidProcDto.Name))
                    {
                        validAnimalAid = false;
                        break;
                    }

                    AnimalAid animalAid = context.AnimalAids.FirstOrDefault(x => x.Name == animalAidProcDto.Name);

                    if (animalAid == null)
                    {
                        validAnimalAid = false;
                        break;
                    }

                    animalAids.Add(animalAid);
                }

                if (!validAnimalAid)
                {
                    sb.AppendLine(errorMsg);
                    continue;
                }

                Procedure procedure = new Procedure
                {
                    Animal = animal,
                    Vet = vet,
                    DateTime = date,
                };

                foreach (var i in animalAids)
                {
                    ProcedureAnimalAid procedureAnimalAid = new ProcedureAnimalAid
                    {
                        AnimalAid = i,
                        Procedure = procedure
                    };

                    procedureAnimalAids.Add(procedureAnimalAid);
                }

                sb.AppendLine(successMgsPocedure);
            }

            context.ProceduresAnimalAids.AddRange(procedureAnimalAids);
            context.SaveChanges();

            return sb.ToString().TrimEnd();
        }

        private static bool IsValid(object obj)
        {
            var validationContext = new ValidationContext(obj);
            var validationResult = new List<ValidationResult>();

            return Validator.TryValidateObject(obj, validationContext, validationResult, true);
        }
    }
}
