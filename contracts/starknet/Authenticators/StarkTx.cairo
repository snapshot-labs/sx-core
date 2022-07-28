%lang starknet
from contracts.starknet.lib.execute import execute
from starkware.starknet.common.syscalls import get_caller_address
from starkware.cairo.common.cairo_builtins import BitwiseBuiltin

@external
func authenticate{syscall_ptr : felt*, range_check_ptr}(
    target : felt, function_selector : felt, calldata_len : felt, calldata : felt*
) -> ():
    let (caller_address) = get_caller_address()

    with_attr error_message("Incorrect caller"):
        assert caller_address = calldata[0]
    end

    # Call the contract
    execute(target, function_selector, calldata_len, calldata)

    return ()
end
