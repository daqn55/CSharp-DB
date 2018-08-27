namespace SoftJail.DataProcessor
{

    using Data;
    using Newtonsoft.Json;
    using SoftJail.Data.Models;
    using SoftJail.Data.Models.Enums;
    using SoftJail.DataProcessor.ImportDto;
    using System;
    using System.Collections.Generic;
    using System.ComponentModel.DataAnnotations;
    using System.Globalization;
    using System.IO;
    using System.Linq;
    using System.Text;
    using System.Xml.Serialization;

    public class Deserializer
    {
        private const string ErrorMsg = "Invalid Data";
        private const string SuccessMsgCell = "Imported {0} with {1} cells";
        private const string SuccessMsgPrisoner = "Imported {0} {1} years old";
        private const string SuccessMsgOfficers = "Imported {0} ({1} prisoners)";

        private static List<Prisoner> Prisoners = new List<Prisoner>();
        private static List<Mail> Mails = new List<Mail>();
        private static List<Department> Departments = new List<Department>();
        private static List<Cell> Cells = new List<Cell>();

        public static string ImportDepartmentsCells(SoftJailDbContext context, string jsonString)
        {
            var sb = new StringBuilder();

            var json = JsonConvert.DeserializeObject<DepartmentDto[]>(jsonString);

            var departments = new List<Department>();
            var cellsToAdd = new List<Cell>();

            foreach (var departmentDto in json)
            {
                var cells = new List<Cell>();

                bool validCell = true;

                if (!IsValid(departmentDto))
                {
                    sb.AppendLine(ErrorMsg);
                    continue;
                }

                Department department = new Department
                {
                    Name = departmentDto.Name
                };

                foreach (var cellDto in departmentDto.Cells)
                {
                    if (!IsValid(cellDto))
                    {
                        validCell = false;
                        break;
                    }

                    Cell cell = new Cell
                    {
                        CellNumber = cellDto.CellNumber,
                        HasWindow = cellDto.HasWindow,
                        Department = department
                    };

                    cells.Add(cell);
                }

                if (!validCell)
                {
                    sb.AppendLine(ErrorMsg);
                    continue;
                }

                cellsToAdd.AddRange(cells);
                departments.Add(department);

                sb.AppendLine(string.Format(SuccessMsgCell, department.Name, cells.Count));
            }

            Departments.AddRange(departments);
            Cells.AddRange(cellsToAdd);

            context.Departments.AddRange(departments);
            context.SaveChanges();

            context.Cells.AddRange(cellsToAdd);
            context.SaveChanges();

            return sb.ToString().TrimEnd();
        }

        public static string ImportPrisonersMails(SoftJailDbContext context, string jsonString)
        {
            var sb = new StringBuilder();

            var json = JsonConvert.DeserializeObject<PrisonerDto[]>(jsonString);

            var prisoners = new List<Prisoner>();
            var mailsToAdd = new List<Mail>();

            foreach (var prisonerDto in json)
            {
                bool mailIsValid = true;
                var mails = new List<Mail>();

                if (!IsValid(prisonerDto))
                {
                    sb.AppendLine(ErrorMsg);
                    continue;
                }

                if (!prisonerDto.Nickname.StartsWith("The "))
                {
                    sb.AppendLine(ErrorMsg);
                    continue;
                }
                else
                {
                    bool onlyLetters = true;

                    if (char.IsUpper(prisonerDto.Nickname[4]))
                    {
                        for (int i = 5; i < prisonerDto.Nickname.Length; i++)
                        {
                            if (!char.IsLetter(prisonerDto.Nickname[i]))
                            {
                                onlyLetters = false;
                                break;
                            }
                        }
                    }
                    else
                    {
                        onlyLetters = false;
                    }

                    if (!onlyLetters)
                    {
                        sb.AppendLine(ErrorMsg);
                        continue;
                    }
                }

                var incarcerationDate = DateTime.ParseExact(prisonerDto.IncarcerationDate, "dd/MM/yyyy", CultureInfo.InvariantCulture);
                DateTime? releaseDate = null;
                if (prisonerDto.ReleaseDate != null)
                {
                    releaseDate = DateTime.ParseExact(prisonerDto.ReleaseDate, "dd/MM/yyyy", CultureInfo.InvariantCulture);
                }

                Prisoner prisoner = new Prisoner
                {
                    FullName = prisonerDto.FullName,
                    Nickname = prisonerDto.Nickname,
                    Age = prisonerDto.Age,
                    IncarcerationDate = incarcerationDate,
                    ReleaseDate = releaseDate,
                    Bail = prisonerDto.Bail,
                    CellId = prisonerDto.CellId
                };

                foreach (var mailDto in prisonerDto.Mails)
                {
                    if (!IsValid(mailDto))
                    {
                        mailIsValid = false;
                        break;
                    }

                    if (mailDto.Address.EndsWith(" str."))
                    {
                        for (int i = 0; i < mailDto.Address.Length-4; i++)
                        {
                            if (!char.IsNumber(mailDto.Address[i]) && !char.IsLetter(mailDto.Address[i]) && !char.IsWhiteSpace(mailDto.Address[i]))
                            {
                                mailIsValid = false;
                                break;
                            }
                        }
                    }
                    else
                    {
                        mailIsValid = false;
                        break;
                    }

                    if (!mailIsValid)
                    {
                        break;
                    }

                    Mail mail = new Mail
                    {
                        Address = mailDto.Address,
                        Description = mailDto.Description, 
                        Sender = mailDto.Sender,
                        Prisoner = prisoner
                    };

                    mails.Add(mail);
                }

                if (!mailIsValid)
                {
                    sb.AppendLine(ErrorMsg);
                    continue;
                }

                mailsToAdd.AddRange(mails);
                prisoners.Add(prisoner);

                sb.AppendLine(string.Format(SuccessMsgPrisoner, prisoner.FullName, prisoner.Age));
            }

            Prisoners.AddRange(prisoners);
            Mails.AddRange(mailsToAdd);

            context.Prisoners.AddRange(prisoners);
            context.SaveChanges();

            context.Mails.AddRange(mailsToAdd);
            context.SaveChanges();

            return sb.ToString().TrimEnd();
        }

        public static string ImportOfficersPrisoners(SoftJailDbContext context, string xmlString)
        {
            var sb = new StringBuilder();

            var xml = new XmlSerializer(typeof(OfficerDto[]), new XmlRootAttribute("Officers"));
            var deserializerOrders = (OfficerDto[])xml.Deserialize(new StringReader(xmlString));

            List<OfficerPrisoner> officerPrisoners = new List<OfficerPrisoner>();

            foreach (var officerDto in deserializerOrders)
            {
                bool validPrisoner = true;
                var prisoners = new List<Prisoner>();

                if (!IsValid(officerDto))
                {
                    sb.AppendLine(ErrorMsg);
                    continue;
                }

                var position = Enum.TryParse<Position>(officerDto.Position, out Position positionEnum);

                if (!position)
                {
                    sb.AppendLine(ErrorMsg);
                    continue;
                }

                var weapon = Enum.TryParse<Weapon>(officerDto.Weapon, out Weapon weaponEnum);

                if (!weapon)
                {
                    sb.AppendLine(ErrorMsg);
                    continue;
                }

                var department = Departments.FirstOrDefault(x => x.Id == officerDto.DepartmentId);
                if (department == null)
                {
                    sb.AppendLine(ErrorMsg);
                    continue;
                }

                foreach (var prisonerDto in officerDto.Prisoners)
                {
                    var prisoner = Prisoners.FirstOrDefault(x => x.Id == prisonerDto.PrisonerId);

                    if (prisoner == null)
                    {
                        validPrisoner = false;
                        break;
                    }

                    prisoners.Add(prisoner);
                }

                if (!validPrisoner)
                {
                    sb.AppendLine(ErrorMsg);
                    continue;
                }

                Officer officer = new Officer
                {
                    FullName = officerDto.FullName,
                    Department = department,
                    Position = positionEnum,
                    Salary = officerDto.Salary,
                    Weapon = weaponEnum
                };

                foreach (var p in prisoners)
                {
                    OfficerPrisoner officerPrisoner = new OfficerPrisoner
                    {
                        Officer = officer,
                        Prisoner = p
                    };

                    officerPrisoners.Add(officerPrisoner);
                }

                sb.AppendLine(string.Format(SuccessMsgOfficers, officer.FullName, prisoners.Count));
            }

            context.OfficersPrisoners.AddRange(officerPrisoners);
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