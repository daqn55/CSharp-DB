using AutoMapper;
using AutoMapper.QueryableExtensions;
using AutoMappingObjects.Data;
using AutoMappingObjects.Data.Models;
using AutoMappingObjects.DTOs;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace AutoMappingObjects.Commands
{
    public class EmployeeCommands
    {
        private readonly EmployeesDbContext context;
        private readonly IMapper mapper;

        public EmployeeCommands(EmployeesDbContext context, IMapper mapper)
        {
            this.context = context;
            this.mapper = mapper;
        }

        public string AddEmployee(string[] args)
        {
            var firstName = args[0];
            var lastName = args[1];
            var salary = decimal.Parse(args[2]);

            EmployeeDto employeeDto = new EmployeeDto()
            {
                FirstName = firstName,
                LastName = lastName,
                Salary = salary
            };

            var employee = mapper.Map<Employee>(employeeDto);

            this.context.Employees.Add(employee);

            this.context.SaveChanges();

            return $"Employee {firstName} {lastName} was added successefully!";
        }

        public void SetBirthday(string[] args)
        {
            var id = int.Parse(args[0]);
            var birthday = DateTime.ParseExact(args[1], "dd-MM-yyyy", null);

            var employee = this.context.Employees.Find(id);

            if (employee == null)
            {
                throw new ArgumentException("Invalid Id");
            }

            employee.Birthday = birthday;

            this.context.SaveChanges();
        }

        public void SetAddress(string[] args)
        {
            var id = int.Parse(args[0]);
            var address = args[1];

            var employee = this.context.Employees.Find(id);

            if (employee == null)
            {
                throw new ArgumentException("Invalid Id");
            }

            employee.Address = address;

            this.context.SaveChanges();
        }

        public string EmployeeInfo(int id)
        {
            var employee = this.context.Employees.Find(id);

            var employeeDto = mapper.Map<EmployeeDto>(employee);

            if (employee == null)
            {
                throw new ArgumentException("Invalid Id");
            }

            var result = $"ID:{id} - {employeeDto.FirstName} {employeeDto.LastName} - ${employeeDto.Salary:f2}";

            return result;
        }

        public string EmployeePersonalInfo(int id)
        {
            var employee = this.context.Employees.Find(id);

            var employeePersonalInfoDto = mapper.Map<EmployeePersonalInfoDto>(employee);

            if (employee == null)
            {
                throw new ArgumentException("Invalid Id");
            }

            var result = $"ID:{id} - {employeePersonalInfoDto.FirstName} {employeePersonalInfoDto.LastName} - ${employeePersonalInfoDto.Salary:f2}\r\n" +
                $"Birthday: {employeePersonalInfoDto.Birthday?.ToString("dd-MM-yyyy") ?? ""}\r\n" +
                $"Adrress: {employeePersonalInfoDto.Address}";

            return result;
        }

        public string ListEmployeesOlderThan(int age)
        {
            var employee = this.context.Employees.Where(x => x.Age > age).OrderByDescending(x => x.Salary);


            var sb = new StringBuilder();

            foreach (var e in employee)
            {
                var employeeDto = mapper.Map<EmployeesOlderThanDto>(e);

                var managerName = "[no manager]";
                if (employeeDto.Manager != null)
                {
                    managerName = $"{employeeDto.Manager.FirstName} {employeeDto.Manager.LastName}";
                }

                sb.AppendLine($"{employeeDto.FirstName} {employeeDto.LastName} - ${employeeDto.Salary:f2} - Manager: {managerName}");
            }

            return sb.ToString().TrimEnd();
        }
    }
}
