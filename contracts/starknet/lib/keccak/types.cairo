from starkware.cairo.common.alloc import alloc

struct Keccak256Hash:
    member word_1 : felt
    member word_2 : felt
    member word_3 : felt
    member word_4 : felt
end

struct StorageSlot:
    member word_1 : felt
    member word_2 : felt
    member word_3 : felt
    member word_4 : felt
end

# first 2 words are full
# the last word contains the remaining 4 bytes
struct Address:
    member word_1 : felt
    member word_2 : felt
    member word_3 : felt
end

struct IntsSequence:
    member element : felt*
    member element_size_words: felt
    member element_size_bytes: felt
end

struct RLPItem:
    member firstByte : felt
    member dataPosition : felt
    member length : felt
end

### IntsSequence utilities
func reconstruct_ints_sequence_list{ range_check_ptr }(
    elements_concat: felt*,
    elements_concat_len: felt,
    elements_sizes_words: felt*,
    elements_sizes_words_len: felt,
    elements_sizes_bytes: felt*,
    elements_sizes_bytes_len: felt,
    acc: IntsSequence*,
    acc_len: felt,
    offset: felt,
    current_index: felt):
    alloc_locals

    if current_index == elements_sizes_words_len:
        return ()
    end

    let (current_sequence_element_acc) = alloc()

    let (offset_updated) = slice_arr(
        offset,
        elements_sizes_words[current_index],
        elements_concat,
        elements_concat_len,
        current_sequence_element_acc,
        0,
        0)

    assert acc[current_index] = IntsSequence(
        current_sequence_element_acc,
        elements_sizes_words[current_index],
        elements_sizes_bytes[current_index])


    return reconstruct_ints_sequence_list(
        elements_concat,
        elements_concat_len,
        elements_sizes_words,
        elements_sizes_words_len,
        elements_sizes_bytes,
        elements_sizes_bytes_len,
        acc,
        acc_len + 1,
        offset_updated,
        current_index + 1)
end

func slice_arr{ range_check_ptr }(
    start: felt,
    size: felt,
    arr: felt*,
    arr_len: felt,
    acc: felt*,
    acc_len: felt,
    current_index: felt) -> (offset: felt):
    if current_index == size:
        return (start + current_index)
    end

    assert acc[current_index] = arr[start + current_index]

    return slice_arr(
        start,
        size,
        arr,
        arr_len,
        acc,
        acc_len + 1,
        current_index + 1)
end