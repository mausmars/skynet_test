function fun(x)
    print(type(x))
    print("s=[" .. x.s .. "]")
    return x.a + x.b;
end