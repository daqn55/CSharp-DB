﻿namespace PetClinic.Data
{
    using Microsoft.EntityFrameworkCore;
    using PetClinic.Models;
    using System.ComponentModel.DataAnnotations.Schema;

    public class PetClinicContext : DbContext
    {
        public PetClinicContext() { }

        public PetClinicContext(DbContextOptions options)
            :base(options) { }

        public DbSet<Passport> Passports { get; set; }
        public DbSet<Animal> Animals { get; set; }
        public DbSet<Procedure> Procedures { get; set; }
        public DbSet<Vet> Vets { get; set; }
        public DbSet<AnimalAid> AnimalAids { get; set; }
        public DbSet<ProcedureAnimalAid> ProceduresAnimalAids { get; set; }

        protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
        {
            if (!optionsBuilder.IsConfigured)
            {
                optionsBuilder.UseSqlServer(Configuration.ConnectionString);
            }
        }

        protected override void OnModelCreating(ModelBuilder builder)
        {
            builder.Entity<Animal>().HasOne(x => x.Passport)
                                        .WithOne(x => x.Animal)
                                        .HasForeignKey<Animal>(x => x.PassportSerialNumber);

            builder.Entity<ProcedureAnimalAid>().HasKey(x => new { x.AnimalAidId, x.ProcedureId });
        }
    }
}