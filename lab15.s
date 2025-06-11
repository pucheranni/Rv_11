.section .text
.align 4

.equ SELF_DRIVING_CAR_BASE, 0xFFFF0100

# --------------------------------
# Interrupt and Syscall Handler
# --------------------------------
.globl int_handler
int_handler:
    # Swap to kernel stack using mscratch
    csrrw x5, mscratch, sp        # x5 = old sp (user), sp = mscratch (kernel sp)

    # Save caller-saved registers (x5-x7, x28-x31, x10-x17)
    addi sp, sp, -60              # Allocate space for 15 registers (4 bytes each)
    sw x5, 0(sp)
    sw x6, 4(sp)
    sw x7, 8(sp)
    sw x28, 12(sp)
    sw x29, 16(sp)
    sw x30, 20(sp)
    sw x31, 24(sp)
    sw x10, 28(sp)
    sw x11, 32(sp)
    sw x12, 36(sp)
    sw x13, 40(sp)
    sw x14, 44(sp)
    sw x15, 48(sp)
    sw x16, 52(sp)
    sw x17, 56(sp)

    # Get cause of trap
    csrr x5, mcause            # Load cause of the trap into x5
    addi x6, x0, 8             # ecall from U-mode has cause code 8
    bne x5, x6, other_exception

    # Read syscall number from x17 (a7)
    addi x5, x17, 0

    # Dispatch syscalls
    addi x6, x0, 10
    beq x5, x6, syscall_set_engine_and_steering
    addi x6, x0, 11
    beq x5, x6, syscall_set_hand_brake
    addi x6, x0, 12
    beq x5, x6, syscall_read_line_camera
    addi x6, x0, 15
    beq x5, x6, syscall_get_position

    # Unrecognized syscall
    j syscall_return

# --------------------------------
# Syscall Implementations
# --------------------------------

# Syscall 10: syscall_set_engine_and_steering
.globl syscall_set_engine_and_steering
syscall_set_engine_and_steering:
    # Parameters:
    # x10 (a0): Movement direction (-1, 0, 1)
    # x11 (a1): Steering wheel angle (-127 to +127)
    # Return value: 0 if successful, -1 if failed (invalid parameters)

    # Validate movement direction
    addi x6, x0, -1
    bge x10, x6, dir_check_upper
    addi x10, x0, -1             # Return -1 for invalid parameter
    j syscall_return
dir_check_upper:
    addi x6, x0, 1
    ble x10, x6, dir_ok
    addi x10, x0, -1             # Return -1 for invalid parameter
    j syscall_return
dir_ok:
    # Validate steering angle
    addi x6, x0, -127
    bge x11, x6, steering_check_upper
    addi x10, x0, -1             # Return -1 for invalid parameter
    j syscall_return
steering_check_upper:
    addi x6, x0, 127
    ble x11, x6, steering_set
    addi x10, x0, -1             # Return -1 for invalid parameter
    j syscall_return
steering_set:
    # Set steering and engine using MMIO
    lui x6, %hi(SELF_DRIVING_CAR_BASE)
    addi x6, x6, %lo(SELF_DRIVING_CAR_BASE)  # Load base address into x6
    sb x11, 0x20(x6)               # Set steering angle (offset 0x20)
    sb x10, 0x21(x6)               # Set engine direction (offset 0x21)
    addi x10, x0, 0                # Success
    j syscall_return

# Syscall 11: syscall_set_hand_brake
.globl syscall_set_hand_brake
syscall_set_hand_brake:
    # Parameters:
    # x10 (a0): 1 to engage hand brake, 0 to release
    # Return value: None

    lui x6, %hi(SELF_DRIVING_CAR_BASE)
    addi x6, x6, %lo(SELF_DRIVING_CAR_BASE)  # Load base address into x6
    sb x10, 0x22(x6)               # Set hand brake (offset 0x22)
    j syscall_return

# Syscall 12: syscall_read_line_camera
.globl syscall_read_line_camera
syscall_read_line_camera:
    # Parameters:
    # x10 (a0): Address to store 256-byte image
    # Return value: None

    lui x6, %hi(SELF_DRIVING_CAR_BASE)
    addi x6, x6, %lo(SELF_DRIVING_CAR_BASE)  # Load base address into x6
    addi x7, x0, 1                      # Value to trigger line camera
    sb x7, 0x08(x6)               # Corrected offset for trigger (offset 0x08)

wait_line_camera:
    lbu x28, 0x0C(x6)               # Corrected offset for status (offset 0x0C)
    bne x28, x0, wait_line_camera  # Wait until status is 0 (capture complete)

    # Copy image data from MMIO to user buffer
    addi x7, x6, 0x100             # x7 = base + 0x100 (line camera data)
    addi x29, x10, 0               # Destination buffer pointer
    addi x30, x0, 256              # Number of bytes to copy

copy_line_camera:
    lbu x28, 0(x7)                  # Load unsigned byte from line camera
    sb x28, 0(x29)                 # Store byte to user buffer
    addi x7, x7, 1                 # Increment source pointer
    addi x29, x29, 1               # Increment destination pointer
    addi x30, x30, -1              # Decrement byte count
    bnez x30, copy_line_camera     # Continue if more bytes to copy

    j syscall_return

# Syscall 15: syscall_get_position
.globl syscall_get_position
syscall_get_position:
    # Parameters:
    # x10 (a0): Address for x position
    # x11 (a1): Address for y position
    # x12 (a2): Address for z position
    # Return value: None

    lui x6, %hi(SELF_DRIVING_CAR_BASE)
    addi x6, x6, %lo(SELF_DRIVING_CAR_BASE)  # Load base address into x6
    addi x7, x0, 1                      # Value to trigger GPS
    sb x7, 0x00(x6)               # Trigger GPS reading (offset 0x00)

wait_gps:
    lbu x28, 0x04(x6)               # Corrected offset for status (offset 0x04)
    bne x28, x0, wait_gps          # Wait until status is 0 (reading complete)

    # Read positions from MMIO and store in provided addresses
    lw x29, 0x10(x6)               # Read X position (offset 0x10)
    sw x29, 0(x10)                 # Store X position
    lw x29, 0x14(x6)               # Read Y position (offset 0x14)
    sw x29, 0(x11)                 # Store Y position
    lw x29, 0x18(x6)               # Read Z position (offset 0x18)
    sw x29, 0(x12)                 # Store Z position

    j syscall_return

# Handle other exceptions (if any)
.globl other_exception
other_exception:
    # For simplicity, just return
    j syscall_return

# Return from syscall handler
.globl syscall_return
syscall_return:
    # Update mepc to return after ecall
    csrr x6, mepc
    addi x6, x6, 4
    csrw mepc, x6

    # Restore caller-saved registers
    lw x5, 0(sp)
    lw x6, 4(sp)
    lw x7, 8(sp)
    lw x28, 12(sp)
    lw x29, 16(sp)
    lw x30, 20(sp)
    lw x31, 24(sp)
    lw x10, 28(sp)
    lw x11, 32(sp)
    lw x12, 36(sp)
    lw x13, 40(sp)
    lw x14, 44(sp)
    lw x15, 48(sp)
    lw x16, 52(sp)
    lw x17, 56(sp)
    addi sp, sp, 60             # Deallocate stack space

    # Swap back to user stack
    csrrw sp, mscratch, sp        # sp = mscratch (user sp), mscratch = sp (kernel sp)

    mret                           # Return to user mode

# --------------------------------
# Program Entry Point
# --------------------------------
.globl _start
_start:
    # Initialize kernel stack
    la sp, kernel_stack_end        # Set sp to kernel stack end

    # Save kernel stack pointer in mscratch
    csrw mscratch, sp

    # Set mtvec to point to the interrupt handler
    la x5, int_handler
    csrw mtvec, x5

    # Switch to user stack
    la sp, user_stack_end

    # Set mepc to user_main (defined in main.s)
    la x5, user_main
    csrw mepc, x5

    # Set machine mode to user mode (MPP = 00)
    csrr x5, mstatus
    li x6, ~(3 << 11)               # Clear MPP bits (bits 12 and 11)
    and x5, x5, x6
    csrw mstatus, x5

    mret                            # Jump to user_main in user mode

# --------------------------------
# Control Logic Function (User Mode)
# --------------------------------
.globl control_logic
control_logic:
    # Release hand brake
    addi x10, x0, 0                  # 0: release
    addi x17, x0, 11                 # syscall_set_hand_brake
    ecall

    # Start engine moving forward with steering angle -15
    addi x10, x0, 1                  # Movement direction: forward
    addi x11, x0, -15                  # Steering angle
    addi x17, x0, 10                 # syscall_set_engine_and_steering
    ecall
    bne x10, x0, exit                # If error, exit

main_loop:
    # Read line camera data
    la x10, line_camera_data         # Address to store line camera data
    addi x17, x0, 12                 # syscall_read_line_camera
    ecall

    # Process line camera data to find line position
    # Initialize variables
    addi x5, x0, 0                   # Sum of pixel values * positions
    addi x6, x0, 0                   # Sum of pixel values
    addi x7, x0, 0                   # Position index (0 to 255)
    la x18, line_camera_data         # Pointer to line camera data

    addi x19, x0, 256                # Loop over 256 pixels

process_line_camera_loop:
    lbu x20, 0(x18)                  # Load unsigned pixel value
    add x6, x6, x20                  # x6 += pixel value
    mul x21, x20, x7                 # x21 = pixel value * position
    add x5, x5, x21                  # x5 += x21
    addi x18, x18, 1                 # Increment buffer pointer
    addi x7, x7, 1                   # x7++
    blt x7, x19, process_line_camera_loop

    # Calculate centroid = x5 / x6
    beq x6, x0, no_line_detected     # If x6 == 0, no line detected
    div x22, x5, x6                  # x22 = centroid position (0 to 255)

    # Calculate steering angle based on centroid
    # Assuming center is at position 128
    addi x23, x0, 128
    sub x24, x22, x23                # x24 = centroid - 128

    # Scale down the steering angle
    srai x24, x24, 4                 # x24 = x24 / 16

    # Ensure x24 is within -15 to 15
    addi x25, x0, -15
    addi x26, x0, 15
    bge x24, x25, steering_angle_min_ok
    addi x24, x25, 0                 # x24 = -15
steering_angle_min_ok:
    ble x24, x26, steering_angle_set
    addi x24, x26, 0                 # x24 = 15

steering_angle_set:
    # Update steering angle
    addi x10, x0, 1                  # Movement direction: forward
    add x11, x24, x0                 # Steering angle
    addi x17, x0, 10                 # syscall_set_engine_and_steering
    ecall
    bne x10, x0, exit                # If error, exit

    # Check if within target area
    # Get current position
    la x10, x_pos                    # Address for x position
    la x11, y_pos                    # Address for y position
    la x12, z_pos                    # Address for z position
    addi x17, x0, 15                 # syscall_get_position
    ecall

    # Calculate squared distance to target (73, 1, -19)
    lw x5, x_pos                     # Load x position
    lw x6, y_pos                     # Load y position
    lw x7, z_pos                     # Load z position

    addi x18, x0, 73
    sub x19, x5, x18                 # x19 = x - 73
    mul x19, x19, x19                # x19 = (x - 73)^2

    addi x18, x0, 1
    sub x20, x6, x18                 # x20 = y - 1
    mul x20, x20, x20                # x20 = (y - 1)^2

    addi x18, x0, -19
    sub x21, x7, x18                 # x21 = z - (-19) = z + 19
    mul x21, x21, x21                # x21 = (z + 19)^2

    add x22, x19, x20                # x22 = sum of squares
    add x22, x22, x21

    addi x23, x0, 225                # Radius squared (15^2)
    blt x22, x23, target_reached     # If within radius, go to target_reached

    j main_loop                      # Otherwise, continue loop

target_reached:
    # Apply hand brake
    addi x10, x0, 1                  # 1: apply
    addi x17, x0, 11                 # syscall_set_hand_brake
    ecall

    # Stop engine
    addi x10, x0, 0                  # Movement direction: off
    addi x11, x0, 0                  # Steering angle: doesn't matter
    addi x17, x0, 10                 # syscall_set_engine_and_steering
    ecall

exit:
    ret                              # Return from control_logic

no_line_detected:
    # No line detected, set steering angle to zero
    addi x10, x0, 1                  # Movement direction: forward
    addi x11, x0, 0                  # Steering angle
    addi x17, x0, 10                 # syscall_set_engine_and_steering
    ecall
    bne x10, x0, exit                # If error, exit
    j main_loop

# --------------------------------
# Data Section
# --------------------------------
.section .data
.align 4
x_pos: .word 0
y_pos: .word 0
z_pos: .word 0

# --------------------------------
# Stack Definitions and Buffers
# --------------------------------
.section .bss
.align 4
line_camera_data:
    .space 256                      # Buffer for line camera data

user_stack:
    .space 4096                      # 4KB user stack
user_stack_end:

kernel_stack:
    .space 4096                      # 4KB kernel stack
kernel_stack_end:
