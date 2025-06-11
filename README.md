# Rv_11

[Skip to content](https://ic.unicamp.br/~allanms/mc404-S12025/labs/Lab-11/#laboratorio-11-digirindo-pela-mc404-town)
{
  "title": "RISC-V Assembly Programmer’s Handbook",
  "description": "This chapter is a placeholder for an assembly programmer’s manual. It includes assembler mnemonics for integer and floating-point registers, as well as standard RISC-V pseudoinstructions.",
  "tables": [
    {
      "table_number": "20.1",
      "title": "Assembler mnemonics for RISC-V integer and floating-point registers",
      "columns": ["Register", "ABI Name", "Description", "Saver"],
      "rows": [
        {"Register": "x0", "ABI Name": "zero", "Description": "Hard-wired zero", "Saver": "—"},
        {"Register": "x1", "ABI Name": "ra", "Description": "Return address", "Saver": "Caller"},
        {"Register": "x2", "ABI Name": "sp", "Description": "Stack pointer", "Saver": "Callee"},
        {"Register": "x3", "ABI Name": "gp", "Description": "Global pointer", "Saver": "—"},
        {"Register": "x4", "ABI Name": "tp", "Description": "Thread pointer", "Saver": "—"},
        {"Register": "x5", "ABI Name": "t0", "Description": "Temporary/alternate link register", "Saver": "Caller"},
        {"Register": "x6–7", "ABI Name": "t1–2", "Description": "Temporaries", "Saver": "Caller"},
        {"Register": "x8", "ABI Name": "s0/fp", "Description": "Saved register/frame pointer", "Saver": "Callee"},
        {"Register": "x9", "ABI Name": "s1", "Description": "Saved register", "Saver": "Callee"},
        {"Register": "x10–11", "ABI Name": "a0–1", "Description": "Function arguments/return values", "Saver": "Caller"},
        {"Register": "x12–17", "ABI Name": "a2–7", "Description": "Function arguments", "Saver": "Caller"},
        {"Register": "x18–27", "ABI Name": "s2–11", "Description": "Saved registers", "Saver": "Callee"},
        {"Register": "x28–31", "ABI Name": "t3–6", "Description": "Temporaries", "Saver": "Caller"},
        {"Register": "f0–7", "ABI Name": "ft0–7", "Description": "FP temporaries", "Saver": "Caller"},
        {"Register": "f8–9", "ABI Name": "fs0–1", "Description": "FP saved registers", "Saver": "Callee"},
        {"Register": "f10–11", "ABI Name": "fa0–1", "Description": "FP arguments/return values", "Saver": "Caller"},
        {"Register": "f12–17", "ABI Name": "fa2–7", "Description": "FP arguments", "Saver": "Caller"},
        {"Register": "f18–27", "ABI Name": "fs2–11", "Description": "FP saved registers", "Saver": "Callee"},
        {"Register": "f28–31", "ABI Name": "ft8–11", "Description": "FP temporaries", "Saver": "Caller"}
      ]
    },
    {
      "table_number": "20.2",
      "title": "RISC-V pseudoinstructions",
      "columns": ["Pseudoinstruction", "Base Instruction(s)", "Meaning"],
      "rows": [
        {
          "Pseudoinstruction": "la rd, symbol",
          "Base Instruction(s)": "auipc rd, symbol[31:12]; addi rd, rd, symbol[11:0]",
          "Meaning": "Load address"
        },
        {
          "Pseudoinstruction": "l{b|h|w|d} rd, symbol",
          "Base Instruction(s)": "auipc rd, symbol[31:12]; l{b|h|w|d} rd, symbol[11:0](rd)",
          "Meaning": "Load global"
        },
        {
          "Pseudoinstruction": "s{b|h|w|d} rd, symbol, rt",
          "Base Instruction(s)": "auipc rt, symbol[31:12]; s{b|h|w|d} rd, symbol[11:0](rt)",
          "Meaning": "Store global"
        },
        {
          "Pseudoinstruction": "fl{w|d} rd, symbol, rt",
          "Base Instruction(s)": "auipc rt, symbol[31:12]; fl{w|d} rd, symbol[11:0](rt)",
          "Meaning": "Floating-point load global"
        },
        {
          "Pseudoinstruction": "fs{w|d} rd, symbol, rt",
          "Base Instruction(s)": "auipc rt, symbol[31:12]; fs{w|d} rd, symbol[11:0](rt)",
          "Meaning": "Floating-point store global"
        },
        {
          "Pseudoinstruction": "nop",
          "Base Instruction(s)": "addi x0, x0, 0",
          "Meaning": "No operation"
        },
        {
          "Pseudoinstruction": "li rd, immediate",
          "Base Instruction(s)": "Myriad sequences",
          "Meaning": "Load immediate"
        },
        {
          "Pseudoinstruction": "mv rd, rs",
          "Base Instruction(s)": "addi rd, rs, 0",
          "Meaning": "Copy register"
        },
        {
          "Pseudoinstruction": "not rd, rs",
          "Base Instruction(s)": "xori rd, rs, -1",
          "Meaning": "One’s complement"
        },
        {
          "Pseudoinstruction": "neg rd, rs",
          "Base Instruction(s)": "sub rd, x0, rs",
          "Meaning": "Two’s complement"
        },
        {
          "Pseudoinstruction": "negw rd, rs",
          "Base Instruction(s)": "subw rd, x0, rs",
          "Meaning": "Two’s complement word"
        },
        {
          "Pseudoinstruction": "sext.w rd, rs",
          "Base Instruction(s)": "addiw rd, rs, 0",
          "Meaning": "Sign extend word"
        },
        {
          "Pseudoinstruction": "seqz rd, rs",
          "Base Instruction(s)": "sltiu rd, rs, 1",
          "Meaning": "Set if = zero"
        },
        {
          "Pseudoinstruction": "snez rd, rs",
          "Base Instruction(s)": "sltu rd, x0, rs",
          "Meaning": "Set if ≠ zero"
        },
        {
          "Pseudoinstruction": "sltz rd, rs",
          "Base Instruction(s)": "slt rd, rs, x0",
          "Meaning": "Set if < zero"
        },
        {
          "Pseudoinstruction": "sgtz rd, rs",
          "Base Instruction(s)": "slt rd, x0, rs",
          "Meaning": "Set if > zero"
        },
        {
          "Pseudoinstruction": "fmv.s rd, rs",
          "Base Instruction(s)": "fsgnj.s rd, rs, rs",
          "Meaning": "Copy single-precision register"
        },
        {
          "Pseudoinstruction": "fabs.s rd, rs",
          "Base Instruction(s)": "fsgnjx.s rd, rs, rs",
          "Meaning": "Single-precision absolute value"
        },
        {
          "Pseudoinstruction": "fneg.s rd, rs",
          "Base Instruction(s)": "fsgnjn.s rd, rs, rs",
          "Meaning": "Single-precision negate"
        },
        {
          "Pseudoinstruction": "fmv.d rd, rs",
          "Base Instruction(s)": "fsgnj.d rd, rs, rs",
          "Meaning": "Copy double-precision register"
        },
        {
          "Pseudoinstruction": "fabs.d rd, rs",
          "Base Instruction(s)": "fsgnjx.d rd, rs, rs",
          "Meaning": "Double-precision absolute value"
        },
        {
          "Pseudoinstruction": "fneg.d rd, rs",
          "Base Instruction(s)": "fsgnjn.d rd, rs, rs",
          "Meaning": "Double-precision negate"
        },
        {
          "Pseudoinstruction": "beqz rs, offset",
          "Base Instruction(s)": "beq rs, x0, offset",
          "Meaning": "Branch if = zero"
        },
        {
          "Pseudoinstruction": "bnez rs, offset",
          "Base Instruction(s)": "bne rs, x0, offset",
          "Meaning": "Branch if ≠ zero"
        },
        {
          "Pseudoinstruction": "blez rs, offset",
          "Base Instruction(s)": "bge x0, rs, offset",
          "Meaning": "Branch if ≤ zero"
        },
        {
          "Pseudoinstruction": "bgez rs, offset",
          "Base Instruction(s)": "bge rs, x0, offset",
          "Meaning": "Branch if ≥ zero"
        },
        {
          "Pseudoinstruction": "bltz rs, offset",
          "Base Instruction(s)": "blt rs, x0, offset",
          "Meaning": "Branch if < zero"
        },
        {
          "Pseudoinstruction": "bgtz rs, offset",
          "Base Instruction(s)": "blt x0, rs, offset",
          "Meaning": "Branch if > zero"
        },
        {
          "Pseudoinstruction": "bgt rs, rt, offset",
          "Base Instruction(s)": "blt rt, rs, offset",
          "Meaning": "Branch if >"
        },
        {
          "Pseudoinstruction": "ble rs, rt, offset",
          "Base Instruction(s)": "bge rt, rs, offset",
          "Meaning": "Branch if ≤"
        },
        {
          "Pseudoinstruction": "bgtu rs, rt, offset",
          "Base Instruction(s)": "bltu rt, rs, offset",
          "Meaning": "Branch if >, unsigned"
        },
        {
          "Pseudoinstruction": "bleu rs, rt, offset",
          "Base Instruction(s)": "bgeu rt, rs, offset",
          "Meaning": "Branch if ≤, unsigned"
        },
        {
          "Pseudoinstruction": "j offset",
          "Base Instruction(s)": "jal x0, offset",
          "Meaning": "Jump"
        },
        {
          "Pseudoinstruction": "jal offset",
          "Base Instruction(s)": "jal x1, offset",
          "Meaning": "Jump and link"
        },
        {
          "Pseudoinstruction": "jr rs",
          "Base Instruction(s)": "jalr x0, rs, 0",
          "Meaning": "Jump register"
        },
        {
          "Pseudoinstruction": "jalr rs",
          "Base Instruction(s)": "jalr x1, rs, 0",
          "Meaning": "Jump and link register"
        },
        {
          "Pseudoinstruction": "ret",
          "Base Instruction(s)": "jalr x0, x1, 0",
          "Meaning": "Return from subroutine"
        },
        {
          "Pseudoinstruction": "call offset",
          "Base Instruction(s)": "auipc x6, offset[31:12]; jalr x1, x6, offset[11:0]",
          "Meaning": "Call far-away subroutine"
        },
        {
          "Pseudoinstruction": "tail offset",
          "Base Instruction(s)": "auipc x6, offset[31:12]; jalr x0, x6, offset[11:0]",
          "Meaning": "Tail call far-away subroutine"
        },
        {
          "Pseudoinstruction": "fence",
          "Base Instruction(s)": "fence iorw, iorw",
          "Meaning": "Fence on all memory and I/O"
        }
      ]
    },
    {
      "table_number": "20.3",
      "title": "Pseudoinstructions for accessing control and status registers",
      "columns": ["Pseudoinstruction", "Base Instruction", "Meaning"],
      "rows": [
        {
          "Pseudoinstruction": "rdinstret[h] rd",
          "Base Instruction": "csrrs rd, instret[h], x0",
          "Meaning": "Read instructions-retired counter"
        },
        {
          "Pseudoinstruction": "rdcycle[h] rd",
          "Base Instruction": "csrrs rd, cycle[h], x0",
          "Meaning": "Read cycle counter"
        },
        {
          "Pseudoinstruction": "rdtime[h] rd",
          "Base Instruction": "csrrs rd, time[h], x0",
          "Meaning": "Read real-time clock"
        },
        {
          "Pseudoinstruction": "csrr rd, csr",
          "Base Instruction": "csrrs rd, csr, x0",
          "Meaning": "Read CSR"
        },
        {
          "Pseudoinstruction": "csrw csr, rs",
          "Base Instruction": "csrrw x0, csr, rs",
          "Meaning": "Write CSR"
        },
        {
          "Pseudoinstruction": "csrs csr, rs",
          "Base Instruction": "csrrs x0, csr, rs",
          "Meaning": "Set bits in CSR"
        },
        {
          "Pseudoinstruction": "csrc csr, rs",
          "Base Instruction": "csrrc x0, csr, rs",
          "Meaning": "Clear bits in CSR"
        },
        {
          "Pseudoinstruction": "csrwi csr, imm",
          "Base Instruction": "csrrwi x0, csr, imm",
          "Meaning": "Write CSR, immediate"
        },
        {
          "Pseudoinstruction": "csrsi csr, imm",
          "Base Instruction": "csrrsi x0, csr, imm",
          "Meaning": "Set bits in CSR, immediate"
        },
        {
          "Pseudoinstruction": "csrci csr, imm",
          "Base Instruction": "csrrci x0, csr, imm",
          "Meaning": "Clear bits in CSR, immediate"
        },
        {
          "Pseudoinstruction": "frcsr rd",
          "Base Instruction": "csrrs rd, fcsr, x0",
          "Meaning": "Read FP control/status register"
        },
        {
          "Pseudoinstruction": "fscsr rd, rs",
          "Base Instruction": "csrrw rd, fcsr, rs",
          "Meaning": "Swap FP control/status register"
        },
        {
          "Pseudoinstruction": "fscsr rs",
          "Base Instruction": "csrrw x0, fcsr, rs",
          "Meaning": "Write FP control/status register"
        },
        {
          "Pseudoinstruction": "frrm rd",
          "Base Instruction": "csrrs rd, frm, x0",
          "Meaning": "Read FP rounding mode"
        },
        {
          "Pseudoinstruction": "fsrm rd, rs",
          "Base Instruction": "csrrw rd, frm, rs",
          "Meaning": "Swap FP rounding mode"
        },
        {
          "Pseudoinstruction": "fsrm rs",
          "Base Instruction": "csrrw x0, frm, rs",
          "Meaning": "Write FP rounding mode"
        },
        {
          "Pseudoinstruction": "fsrmi rd, imm",
          "Base Instruction": "csrrwi rd, frm, imm",
          "Meaning": "Swap FP rounding mode, immediate"
        },
        {
          "Pseudoinstruction": "fsrmi imm",
          "Base Instruction": "csrrwi x0, frm, imm",
          "Meaning": "Write FP rounding mode, immediate"
        },
        {
          "Pseudoinstruction": "frflags rd",
          "Base Instruction": "csrrs rd, fflags, x0",
          "Meaning": "Read FP exception flags"
        },
        {
          "Pseudoinstruction": "fsflags rd, rs",
          "Base Instruction": "csrrw rd, fflags, rs",
          "Meaning": "Swap FP exception flags"
        },
        {
          "Pseudoinstruction": "fsflags rs",
          "Base Instruction": "csrrw x0, fflags, rs",
          "Meaning": "Write FP exception flags"
        },
        {
          "Pseudoinstruction": "fsflagsi rd, imm",
          "Base Instruction": "csrrwi rd, fflags, imm",
          "Meaning": "Swap FP exception flags, immediate"
        },
        {
          "Pseudoinstruction": "fsflagsi imm",
          "Base Instruction": "csrrwi x0, fflags, imm",
          "Meaning": "Write FP exception flags, immediate"
        }
      ]
    }
  ]
}

# Laboratório 11 - Digirindo pela MC404-Town

## 📝 Descrição - Peso 2

Neste laboratório, você deve mover um carrinho de um ponto inicial até um ponto final em menos de 180 segundos. O carro é um dispositivo externo conectado ao processador RISC-V e pode ser acessado e controlado exclusivamente por meio de MMIO.

#### Controlando o Carrinho

Neste exercício você deve APENAS usar a MMIO para controlar o carro. As especificações de MMIO para o carrinho podem ser vistas a seguir:

###### MMIO - Manual

| Endereço | Tamanho | Descrição |
| --- | --- | --- |
| `base+0x00` | byte | Guardar `1` simboliza para que o dispositivo de GPS começe a ler as coordenadas e rotação do carro. É setado para `0` quando a leitura é finalizada. |
| `base+0x01` | byte | Guardar `1` simboliza para que o dispositivo "Line Camera" capture uma imagem. É setado para `0` quando a captura está completa. |
| `base+0x02` | byte | Guardar `1` simboliza para que o dispositivo de Sensor Ultrassônico meça a distância na frente do carro. É setado para `0` quando a medida está completa. |
| `base+0x04` | word | Guarda o ângulo X de Euler da rotação do carro do último momento lido pelo GPS. |
| `base+0x08` | word | Guarda o ângulo Y de Euler da rotação do carro do último momento lido pelo GPS. |
| `base+0x0C` | word | Guarda o ângulo Z de Euler da rotação do carro do último momento lido pelo GPS. |
| `base+0x10` | word | Guarda a coordenada X do carro do último momento lido pelo GPS. |
| `base+0x14` | word | Guarda a coordenada Y do carro do último momento lido pelo GPS. |
| `base+0x18` | word | Guarda a coordenada Z do carro do último momento lido pelo GPS. |
| `base+0x1C` | word | Guarda a distância (em centímetros) entre o Sensor Ultrassônico e o obstáculo mais próximo. Retorna -1 se não tem nenhum obstáculo a menos de 20m. |
| `base+0x20` | byte | Seta a direção do volante. Negativo para a esquerda e positivo para a direita. |
| `base+0x21` | byte | Seta a direção do motor.<br>`1`: Para frente.<br>`0`: Desligado.<br>`-1`: Para trás. |
| `base+0x22` | byte | Seta o freio de mão. (1 = Ligado) |
| `base+0x24` | 256-byte array | Guarda a imagem capturada pela Line Camera. Cada byte representa a luminância de um pixel. |

Você deve utilizar exclusivamente a MMIO para controlar o volante, motor, freios e obter coordenadas do carro. O teste do assistente verificará se o carro alcançou o ponto de destino com precisão suficiente. Certifique-se de que seu código chame a syscall de exit para encerrar a execução corretamente.

#### Infraestrutura

Para usar o carro, primeiro você deve ativar o dispositivo "Self-Driving Car" no simulador. Isso pode ser feito na aba de "Hardware", selecionando o dispositivo "Self-Driving Car" como na imagem a seguir. Depois de adicionar o dispositivo, seu "base address" vai estar listado na tabela:

[![Figure 7.1.2: Memory Map Table](https://riscv-programming.org/ale-exercise-book/book/img/ch07_01_02.png)](https://riscv-programming.org/ale-exercise-book/book/img/ch07_01_02.png)

Feito isso, o carro pode ser acessado na aba esquerda do simulador, como mostrado na imagem a seguir:

[![Figure 7.1.3: Car Menu Tab](https://riscv-programming.org/ale-exercise-book/book/img/ch07_01_03.png)](https://riscv-programming.org/ale-exercise-book/book/img/ch07_01_03.png)

Note que ao adicionar o dispositivo, o carro será posicionado em uma coordenada arbitrária. Para posicioná-lo na posição de teste, utilize o Assistant.

Caso deseje mover o carro manualmente e de forma livre, ative a opção "Enable debug controls" e utilize as teclas de direção ou WASD, conforme demonstrado abaixo:

[![Figure 7.1.4: Debug Controls](https://riscv-programming.org/ale-exercise-book/book/img/ch07_01_04.png)](https://riscv-programming.org/ale-exercise-book/book/img/ch07_01_04.png)

#### ✅ Teste

O assistente irá posicionar o carro em um local específico e seu objetivo é chegar até o poste à sua direita, como é realizado no gif abaixo.

[![Car Challenge GIF](https://i.imgur.com/1wfxyC5.gif)](https://i.imgur.com/1wfxyC5.gif)

## 💡 Dicas

- Os valores de direção do volante vão de -127 até 127. Valores negativos giram a roda para a esquerda e positivos para a direita
- Para debugar, você consegue controlar o carro usando as setas ou WASD, com a opção "Enable debug controls" ativada. Porém, quando for testar no assistente, desative essa opção.
- Quando você entra pelo link da atividade, o simulador já está preparado com o carro.
- Você pode testar seu código a partir do [Link](https://riscv-programming.org/ale/#select_url_content=TjRJZ3RnaGdsZ2RnK2dCd2djd0tZZ0Z3aEFHaEJBWndLZ0lCY0laUzRDQmpBSnlnVk14Q2pBUUhzN1NBQ1lBVlFDU2NBQktvQU5nbFIwY1BBSUpFUzVTbkFESzlScVFDK1BBR1owT1lIZ0IwUUFPZ0QwWURnQk1BcnVOUUVMaFltUXFrekFLd0tuak1OazV1UGdBWkRob0ljUUFsVkNEdFBRTWpVMHRyZTBkbkdnNFlHRlFhVWlnczcxOFFBRzUtUUs1ZUNMb0V3eE56QzFRQUQxSlVHR0lzNXh0VUFEY29HaWNMQWdsZE9Cc0dQcGhrT0dxaXZ4aC1UUGJlVlRrUWdCVWVBRjU2Z2tpcUd3NFppRG9HR0FBTEk1NjZPekE0YTl2VE1vV1lHbkZYSGhDSUFDTUFSbCtlTTFXakFiQVI1SXAzQ3AxQXdtTUItRHdlRXN5RGM4bHdBQlFBU2poTUFSQ0lJZGlrZEV4ejF4UEZJNXhJWmpzVUcyUEJ5QUhjZUVKUkJKQ1dpQUFZQUhuT0FCWUFId0FVU2EwaG9KRlFQQUFIR1pmcHlMTHkrWnp2blErZkRjWXE3S1JTRmt5UUJQS1JiVXpmRFZhaFlnSGhRR3dHa0RWT0N3S0NJRGpGUkh2SWhXNzZrSEh1bUFBV2dRREVnZEIxcGo1cWxRVlJPWkk0NW9DK1VpUEU0eEh5V1ZsUnMxV1JWT0xWcVpOdXYxaHVOV1ZNNXN0cGdKTmdncldPZEFkVHJlcmpkSHA0WHQ5LXBPUVpBZklBNG1IRVJHYUhaVG0xZUFtb0VtWUNtQ3pBTTZURmNyVlFpdm1SZXpVUjJPTUR4T1FRa0RpTFZhYmYzQnlvRThIWlZ1S0h6MlJqbnZPZUlkKzJBaDJZMEtRQlk0SDVRQUVJNndRMk5HbGhEbHBXTnJIaUFHSm1Ga2J6OUFBMXJTY0RiSHlmQ3pIWU1ZNmdBc3JZRGlvR1lvWWdxaFRoN0dnZjdXaWNwaXlLWXo2cU9RcEIyTVVWNWFEZWQ2M0krejZ2cWc3NmtGK1A1RVRhZG8xcVlZRVFlSTBHd2ZCaUVuR1l3eFVPNHJSb3NBVFRycjhBQU1pbG1NcEFDY3NnNnV1S2xxUUE3RHl2eXlBQVhncGlrQUd4bUdwQUJNRW84bG9zaHlkcDBxNlpwNjdlbXBLa1NzWlRtS1ZvZEgrQUZtWjRtR2dpVU5JUFNSR2ltS2lkaXBJSWxBdWhvck1xNEZQQTRnY01nWmlPRk01SThBaGlsWWplcEtNZXhUNWhxeDdHY2IrcGo3Z09kQkRueG9GbUxBT1IwQ0k2eW9TRXRJQUZLcUFBOGdBY2hKcEJuTWdDVTZrbDRrcFZrY0RwY2dBRGF5V09xT3FXelJsV1Z0TWd1WGVqd3Z3QUxwWGtWUEQwVUZ4MnlBQXJNcGgwdktTamk4RDBZWmNMUzgxN1NTdUozVHc5VnhMU0RLZk9Fa1F4SEV4STN1U2xKTERrZVNwUVFaZ0lEUjV4b2w5bFRYYVNvUFEzNnFEZExvc0FZM0FKeklHQ096emFZM3JlZ3lRbmZLUjlRazVKOVhJSlRwaGJsc2lsTkxwQUJpN1Bzd0F3dlRJQWt5UUVBOHhBTkEyRmpZRDRxWXIwZ3hTMFBVbVlFQTJEWWNDdEdRZjZuUWlwaWM0WUNCUU84WTZrVWRjRmJBaHNWeFFpaVBjR1k5WHVOd3dOcTdpOVhVWFFPS28yVnJYOURNV3M2NmdTdE9LUW1LMjZiT2hrWGJ3QjZOQTRod0tnSnppRnBaSTNPS0oya3NqdUl1N0w4dUs4cmZ1bUFBQ2ljVUd3TWdmMjhGcVBEckw3QmVsM1FRdFFaVGhBNnE4ZWpJWkQyclJTYnBLekpKMUJVYWdzbnlidHltcVlwR2s4TEhPbjZZWlBBbWYzRm5XYlo5bDhIM0ttLUM1STl1UjVaaGVaUFBsK1c5N2RUY3RZNXJZWGhPUzNiRDFhalVKKzc3aUNWb2dBaEdpRUQwdEF4ZlM1YnlIVUd3RGdWdWlHSi0yM2NWVTVRQ3lobElpQTBveFkwY0R3WVlqZzhnWTM0dGZGR2I4NXBnSWdWN2FCRWhjaXRCc0FnbzZac3d3RGh4TG9TSXd4RUhIVUNxYkpFSEJIQWdPUUVSQUFWSXdwaHpDb2o4QUdnTlFRQTFPek1KNFV3M0JOMDRwSW1MbmpIc094SElBR1lwVG5SWGxwTWUzbGZobVhFV1lNeWRranE2Q2VtaUQ2dkFkaUtSS0dTRGNQQnhGbVYwV1NBQTFLWWpFZkE4SExpcENoZENhUXNJNFJzSGhJZ0tBZTQxUklyZ2VvRkVxSTBYNGFiQkVUOFg1a2pmZ1FSd3NRMFNYUUttUWhFVkNhRW9OTUx3NWhnMEJTbDBFS2hBVXFoMWdDbXpra25oeGdBcWdSaWVhUktTMUV5clRtaHRISzV3OG84QUtnQTAyNThubzdEa0tjQ0FPb3pENkVNSk5PZ01NRDRWSXloaWF4aWNBa0pSNEdpSnB2VHNwYlJxZmxTeERUQkdkR0hJNldra3o1cVRLcVRNbmdPMTlyRk5pVXMyOFNoYVNvUXJPY0NTQUJIRzJhSnlCMEdmR1lKbzJ6NHlPbnVSaVJoVmtlQ21QR1RjdTVPcEhrSmpNRHFWNTlEM21mT3VTSXp3UmstblBLTWtDcXlReTdidDA2TlFyQ0tEMlI1SjRKekNNMDBjUVZqSkZzQUFKTUFiUTY0MFNFditVMGVlWkxuazZrcGNBZjVSay1KbUI0QUFFU1VCUUFZdFFqRGZKN0xpMGxSTHdYM05wZHl6d05MWkNFdUZXWUJsR0oxeUVwc0VvZWktaEx4N0pLV2lPVlM1T1E3RitPZFFxQ0xBSElOQWJNVEk0Z2hJZERTb001VkNJWFlvTEtTdEdhYzFrNEJKVHFFclVDQlA1Z0ctaGZBT2pyN1lFS2RuSE93cUJsVWpNRGtkWU51STRrb3RBWWs1aHBjMkNvQTRCcUhnTVFoYm5BeGp3UEotaTlXVW10ZUpJMUpxQm5JQWRVNjdOQnI5N2xMdGVhbzZMc3lBY0ZkY1FkMXV0ZjVrSWRvUXNPNGhTRTNpMEdZYjRzQmZ5b3otdGVVNlFET213RWlIQUsyRGh0RThEcmczUTJmSUZubTA4SXVvbUlCTTdqcWNKTzRvZTFhVERyWFJPOFFwQUNCa052bmZYZHZ0MTM0Z1BRUWVhaWtEcWZWOVRpUHdwUWpvZldRRlhib3RKZEZxSTBSOUdrbXE5RTBrNUNFeWtzczkwYnF2WnM4a0FIekh6T3NXKytXNHBURTdEUFdRQzltNzVwUUQydlFwU1pDdzM0TGlKYldJbFFWMVl4Z0dPK0QzUUphMGdvNEdsOVBadmpwVytMU1JkcnRwQVZtOW91cjF0MGV6bkVJT2NEOGpIYVJCTkhOT2hXcWg5Z1l4RUh4OVlIQUJNY0crR2lCajhuWkNyQTJFVy1CanNjVHNuQWVRR1Z3QWFOZHA0QithQXdvTUYySHZickFBend3S01IN003aW5MSUNZVS1ZQURuQUJqMnpVWUZCdUdCSzBEY0VBZURuSHFyb0Fsd0I2UzlvNFBTTXctQW9naERNUFFLT3JRK3JmQzhGZ21MSVEwUzhZSVB4eGpHSWRDSEhwREFkSzhzclR2RCtMOE9BVVE1QUFBMWF2VmNJM0VZTVNVaExuSURkTzFyVUFNU3lnZ0h5TXc3Sk8ycWhPaWRmd002YUNOMWVHT1VUTmh4TUhzazlKMlRqSEZPTWRrSHNBOXNITXdmUk9GWEhVSDQ3QzZGME5JSVR6OFJOS2UrSExOcE8yOXNIYUpNbkQ2cTJPSlhjT3pzWDZaY1dnQ2xlTFlhUW1JekJ0RXlOME5FOTNiczludXhqWGIrMm50MGxRSXlmZ3NCU0FTbGFkdHgrRjJ3ZlhlN1RxVm9JUk5xNVUrZmRsSDBnMGNZNngrY1pPSU9iQjQ5NlpKTkV2MFllVUhoeGRwSDIzeWNZbGtORTFVcFB5Y1NUREFELVk1UFpCYmZhUno3NDZQVUNZK3FkZFZVSDBzdjhjZTVmYWR4MnFpQmlZQndDU2RoM1EwTGxXZ0ZXQUJ5VlFJZzVEZWlzdWRNeVd1VnNTYkp6TDd0TXVnZThDbHdqOXB0STdjZEs2V0FLblVPbVN3N3A0anFYVFByZUJiNDJJQjVPeGJjWGJNSkFCQWluUkpuYTFKUlVhYUlGRmdTUU5ObTVmc3JLeUMxNHBMWGY5dkFjRmdHaUxYbWZCMGFkYmI5T1RDbjVyODh1K0RtUWZ2c3NCNE9zOFliTHhmcGZISzdiWEExb3NoWTJRSmdVQXRheHdFQjd4M21BWGZiUjdEa0pnRWFBYThCTEJILXpUbUUtNDdUODcxQWFZLU5tVUw2bjBQMmZleFdZYjlRRXY0ZkstUjhRRUVIdmctMitJQ29UUDF2by0tTlZEWDVuN2Z2WS1Ccjl0QitJNGFnUndhQ3Bwb0ZCYjRIQW1ocjhDQWpoM0JmOEhSWWRwQjdoSWdBMFdCbVkyWU9aV1o1ODhCWWM0QjlCVUJ6bHgwS0EwQVdCRGNRQjdJUUFDQWRSYUJJaDIwZTk4RHVnK2dCZ0I4TUJRQVlGUmh4Z29CSmhwaFpnZkJCOHdrT0JtQU1CRGN6SXRCZUN0QWdB).

Warning

- Qualquer alteração no arquivo de report será considerado **fraude**
- Esta é uma atividade que deve ser realizada programando-se em linguagem de montagem - A submissão de programas em linguagem de programação de alto nível, como `C`, ou de programas gerados por ferramentas de compilação, serão considerados como **fraude**
- Está é uma atividade individual, o qual deve ser desenvolvido individualmente, qualquer forma de cópia ou plágio será penalizada. Portanto, atividades que apresentarem semelhanças injustificadas serão atribuídas nota zero para todos os envolvidos

Back to top
