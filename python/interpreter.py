def interpret(str, input = ""):
    memory = [0]
    output = ""
    index = 0
    memory_pointer = 0
    input_index = 0
    while index < len(str):
        if str[index] == ">":
            memory_pointer += 1
            if memory_pointer >= len(memory):
                memory.append(0)
            index += 1
        elif str[index] == "<":
            memory_pointer -= 1
            if memory_pointer < 0:
                raise Exception("Memory pointer out of bounds.")
            index += 1
        elif str[index] == "+":
            memory[memory_pointer] += 1
            index += 1
        elif str[index] == "-":
            memory[memory_pointer] -= 1
            index += 1
        elif str[index] == ".":
            output += chr(memory[memory_pointer])
            index += 1
        elif str[index] == ",":
            memory[memory_pointer] = ord(input[input_index])
            input_index += 1
            index += 1
        elif str[index] == "[":
            if memory[memory_pointer] == 0:
                ls = 0
                rs = 0
                for i in range(index, len(str)):
                    if str[i] == "[":
                        ls += 1
                    if str[i] == "]":
                        rs += 1
                    if ls == rs:
                        index = i + 1
                        break
            else:
                index += 1
        elif str[index] == "]":
            if memory[memory_pointer] != 0:
                ls = 0
                rs = 0
                i = index
                while i > 0:
                    if str[i] == "[":
                        ls += 1
                    if str[i] == "]":
                        rs += 1
                    if ls == rs:
                        index = i + 1
                        break
                    i -= 1
            else:
                index += 1
        else:
            index += 1
    return output