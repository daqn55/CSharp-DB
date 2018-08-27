using AutoMapper;
using AutoMappingObjects.Data.Models;
using AutoMappingObjects.DTOs;
using System;
using System.Collections.Generic;
using System.Text;

namespace AutoMappingObjects
{
    public class EmployeeProfile : Profile
    {
        public EmployeeProfile()
        {
            CreateMap<Employee, EmployeeDto>().ReverseMap();
            CreateMap<Employee, EmployeePersonalInfoDto>().ReverseMap();
            CreateMap<Employee, ManagerDto>()
                .ForMember(x => x.EmployeesDto, from => from.MapFrom(m => m.ManagerEmployee))
                .ReverseMap();
            CreateMap<Employee, EmployeesOlderThanDto>()
                .ForMember(x => x.Manager, from => from.MapFrom(m => m.Manager))
                .ReverseMap();
        }
    }
}
