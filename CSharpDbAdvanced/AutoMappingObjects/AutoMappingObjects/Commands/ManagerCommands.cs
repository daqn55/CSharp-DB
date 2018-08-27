using AutoMapper;
using AutoMappingObjects.Data;
using AutoMappingObjects.DTOs;
using System;
using System.Collections.Generic;
using System.Text;

namespace AutoMappingObjects.Commands
{
    public class ManagerCommands
    {
        private readonly EmployeesDbContext context;
        private readonly IMapper mapper;

        public ManagerCommands(EmployeesDbContext context, IMapper mapper)
        {
            this.context = context;
            this.mapper = mapper;
        }

        public string SetManager(string[] args)
        {
            var employeeId = int.Parse(args[0]);
            var managerId = int.Parse(args[1]);

            var employee = this.context.Employees.Find(employeeId);

            var manager = this.context.Employees.Find(managerId);

            if (employee == null || manager == null)
            {
                throw new ArgumentException("Invalid Employee or Manager ID");
            }

            employee.Manager = manager;

            this.context.SaveChanges();

            return "Successefully set Manager!";
        }

        public string ManagerInfo(string[] args)
        {
            var employeeId = int.Parse(args[0]);

            var employee = this.context.Employees.Find(employeeId);

            var managerDto = mapper.Map<ManagerDto>(employee);

            var sb = new StringBuilder();

            sb.AppendLine($"{managerDto.FirstName} {managerDto.LastName} | Employees: {managerDto.EmployeesCount}");

            foreach (var m in managerDto.EmployeesDto)
            {
                sb.AppendLine($"- {m.FirstName} {m.LastName} - ${m.Salary:f2}");
            }

            return sb.ToString().TrimEnd();
        }
    }
}
