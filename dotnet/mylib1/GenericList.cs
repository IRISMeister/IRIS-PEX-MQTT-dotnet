using System;
using System.Collections.Generic;

namespace dc
{
    public class GenericList<T>
    {
        public void Add(T input) {
            Console.WriteLine(input.ToString());
        }
    }

    public class GenericListWrapper
    {
        public GenericList<int> GetIntList() { 
            dc.GenericList<int> list = new dc.GenericList<int>();
            return list;
        }
        public GenericList<string> GetStringList() { 
            dc.GenericList<string> list = new dc.GenericList<string>();
            return list;
        }
    }
}