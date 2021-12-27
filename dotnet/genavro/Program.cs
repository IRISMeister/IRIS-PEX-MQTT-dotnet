using System;

namespace dc
{
    class Program
    {
        static void Main(string[] args)
        {
            Console.WriteLine("Generating avro files.");
            AVROTest();
        }
        static void AVROTest() {
            string schema;
            Object[] objs;

            schema = "[{\"type\": \"array\", \"items\": \"string\"}, \"string\"]";
            object value = new string[] { "aaa", "bbb" };
            var r=GenericReader.test<object>(schema, value);
            objs = (Object[])r;
            Console.WriteLine("{0} objects found.",objs.Length);
            for (int i = 0; i < objs.Length; i++)
            {
                Console.WriteLine("Class={0}, Value={1}", objs[i].GetType().FullName, objs[i].ToString());
            }

            schema = "[{\"type\": \"array\", \"items\": \"float\"}, \"double\"]";
            object fvalue = new float[] { 23.67f, 22.78f };
            r=GenericReader.test<object>(schema, fvalue);
            objs = (Object[])r;
            Console.WriteLine("{0} objects found.",objs.Length);
            for (int i = 0; i < objs.Length; i++)
            {
                Console.WriteLine("Class={0}, Value={1}", objs[i].GetType().FullName, objs[i].ToString());
            }

            schema = "[{\"type\": \"array\", \"items\": \"int\"}, \"int\"]";
            object intvalue = new int[] { 1,2,3,4,5 };
            r = GenericReader.test<object>(schema, intvalue);
            objs = (Object[])r;
            Console.WriteLine("{0} objects found.",objs.Length);
            for (int i = 0; i < objs.Length; i++)
            {
                Console.WriteLine("Class={0}, Value={1}", objs[i].GetType().FullName, objs[i].ToString());
            }

            schema = ComplexClass.SCHEMA;
            ComplexClass z= ComplexClass.Populate();
            r=ReflectReader.protocol<ComplexClass>(schema, z);
            Console.WriteLine(((ComplexClass)r).myString);

            schema=SimpleClass.SCHEMA;
            SimpleClass s= SimpleClass.Populate();
            r=ReflectReader.schema<SimpleClass>(schema, s);
            Console.WriteLine(((SimpleClass)r).myString);

        }



    }
}
