using P01_BillsPaymentSystem.Data.Models;
using System;
using System.Collections.Generic;
using System.Text;

namespace P01_BillsPaymentSystem.Initializer
{
    public class UserInitializer
    {
        public static User[] GetUsers()
        {
            User[] users = new User[]
            {
                new User() {FirstName = "Pesho", LastName = "Georgiev", Email = "pesho@abv.bg", Password = "afsdg23"},
                new User() {FirstName = "Gosho", LastName = "Ivanov", Email = "Gosho@abv.bg", Password = "dgdfhghe"},
                new User() {FirstName = "Ivan", LastName = "Nikolov", Email = "Ivan@abv.bg", Password = "fger35"},
                new User() {FirstName = "Maria", LastName = "Ignatova", Email = "Sunny@abv.bg", Password = "gdfbh64"},
                new User() {FirstName = "Magdalena", LastName = "Keremetchieva", Email = "Magi@abv.bg", Password = "sgfeh6"},
                new User() {FirstName = "Penka", LastName = "Markova", Email = "Pepi@abv.bg", Password = "afsdfr4"},
                new User() {FirstName = "Nikola", LastName = "Nikolov", Email = "Niki@abv.bg", Password = "ghytj7"},
                new User() {FirstName = "Mehmet", LastName = "Donchev", Email = "Memo@abv.bg", Password = "grth6"},
                new User() {FirstName = "Kremena", LastName = "Kapitanova", Email = "Kremi@abv.bg", Password = "bhytjy8"},
                new User() {FirstName = "Cvetan", LastName = "Cvetanov", Email = "ceko@abv.bg", Password = "gfhj87"},
            };

            return users;
        }
    }
}
