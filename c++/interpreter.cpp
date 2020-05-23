#include <iostream>
#include <vector>
#include <string.h>
#include <string>

std::string interpret(std::string str, std::string input) {
    std::vector<int> memory = { 0 };
    std::string output = "";
    int index = 0;
    int memory_pointer = 0;
    int input_index = 0;
    while (index < str.length()) {
        switch (str[index]) {
            case '>':
                memory_pointer++;
                if (memory_pointer >= memory.size()) memory.push_back(0);
                index++;
                break;
            case '<':
                memory_pointer--;
                if (memory_pointer < 0) {
                    std::cerr << "Memory pointer out of bound.";
                    return "";
                }
                index++;
                break;
            case '+':
                memory[memory_pointer]++;
                index++;
                break;
            case '-':
                memory[memory_pointer]--;
                index++;
                break;
            case '.':
                output += char(memory[memory_pointer]);
                index++;
                break;
            case ',':
                memory[memory_pointer] = int(input[input_index++]);
                index++;
                break;
            case '[':
                if (memory[memory_pointer] == 0) {
                    int ls = 0;
                    int rs = 0;
                    for (int i = index; i < str.length(); i++) {
                        switch (str[i]) {
                            case '[':
                                ls++;
                                break;
                            case ']':
                                rs++;
                                break;
                            default:
                                break;
                        }
                        if (ls == rs) {
                            index = i + 1;
                            break;
                        }
                    }
                } else index++;
                break;
            case ']':
                if (memory[memory_pointer] != 0) {
                    int ls = 0;
                    int rs = 0;
                    for (int i = index; i >= 0; i--) {
                        switch (str[i]) {
                            case '[':
                                ls++;
                                break;
                            case ']':
                                rs++;
                                break;
                            default:
                                break;
                        }
                        if (ls == rs) {
                            index = i + 1;
                            break;
                        }
                    }
                } else index++;
                break;
            default:
                index++;
        }
    }
    return output;
}

int main(char *args[]) {
    std::cout << interpret(args[0], args[1]);
    return 0;
}