using AutoMapper;
using AutoMappingObjects.Commands;
using AutoMappingObjects.Data;
using AutoMappingObjects.Data.Models;
using AutoMappingObjects.DTOs;
using System;
using System.Linq;

namespace AutoMappingObjects
{
    public class StartUp
    {
        static void Main()
        {
            using(var context = new EmployeesDbContext())
            {
                var input = Console.ReadLine().Split(" ", StringSplitOptions.RemoveEmptyEntries);

                while (true)
                {
                    var confMapper = new MapperConfiguration(conf => conf.AddProfile<EmployeeProfile>());
                    var mapper = new Mapper(confMapper);

                    EmployeeCommands empCommands = new EmployeeCommands(context, mapper);
                    ManagerCommands managerCommands = new ManagerCommands(context, mapper);

                    var args = input.Skip(1).ToArray();
                    switch (input[0])
                    {
                        case "AddEmployee":
                            Console.WriteLine(empCommands.AddEmployee(args));
                            break;
                        case "SetBirthday":
                            empCommands.SetBirthday(args);
                            break;
                        case "SetAddress":
                            empCommands.SetAddress(args);
                            break;
                        case "EmployeeInfo":
                            var id = int.Parse(args[0]);
                            Console.WriteLine(empCommands.EmployeeInfo(id));
                            break;
                        case "EmployeePersonalInfo":
                            var Employeeid = int.Parse(args[0]);
                            Console.WriteLine(empCommands.EmployeePersonalInfo(Employeeid));
                            break;
                        case "SetManager":
                            Console.WriteLine(managerCommands.SetManager(args));
                            break;
                        case "ManagerInfo":
                            Console.WriteLine(managerCommands.ManagerInfo(args));
                            break;
                        case "ListEmployeesOlderThan":
                            Console.WriteLine(empCommands.ListEmployeesOlderThan(int.Parse(args[0])));
                            break;
                    }

                    if (input[0] == "Exit")
                    {
                        break;
                    }

                    input = Console.ReadLine().Split(" ", StringSplitOptions.RemoveEmptyEntries);
                }
            }
        }
    }
}
