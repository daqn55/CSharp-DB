using AutoMappingObjects.Data.Models;
using Microsoft.EntityFrameworkCore;
using System;

namespace AutoMappingObjects.Data
{
    public class EmployeesDbContext : DbContext
    {
        public EmployeesDbContext()
        { }

        public EmployeesDbContext(DbContextOptions options) : base(options)
        { }

        public DbSet<Employee> Employees { get; set; }

        protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
        {
            if (!optionsBuilder.IsConfigured)
            {
                optionsBuilder.UseSqlServer(Configuration.ConectionString);
            }
        }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            modelBuilder.Entity<Employee>(x =>
            {
                x.HasOne(m => m.Manager)
                 .WithMany(m => m.ManagerEmployee)
                 .HasForeignKey(m => m.ManagerId);
            });
        }
    }
}
