from starkware.cairo.common.math import unsigned_div_rem


func pow{ range_check_ptr }(base: felt, p: felt) -> (res: felt):
    if p == 0:
        return (1)
    end
    
    let (accumulator) = pow(base=base, p=p-1) 
    return (base * accumulator)
end