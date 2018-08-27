using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using P01_BillsPaymentSystem.Data.Models;
using System;
using System.Collections.Generic;
using System.Text;

namespace P01_BillsPaymentSystem.Data.EntityConfig
{
    public class BankAccountConfiguration : IEntityTypeConfiguration<BankAccount>
    {
        public void Configure(EntityTypeBuilder<BankAccount> builder)
        {
            builder.HasOne(x => x.PaymentMethod)
                .WithOne(x => x.BankAccount)
                .HasForeignKey<PaymentMethod>(x => x.BankAccountId);

            builder.Property(x => x.SwiftCode)
                .IsUnicode(false);
        }
    }
}
