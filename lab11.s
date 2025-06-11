.data
# MMIO Base Address - Placeholder, confirm in simulator
MMIO_BASE_ADDR: .word 0xFFFF0000

# MMIO Offsets
GPS_INIT_OFFSET:        .word 0x00 # byte: write 1 to start, reads 0 when done
LINE_CAM_INIT_OFFSET:   .word 0x01 # byte: write 1 to start, reads 0 when done
ULTRASONIC_INIT_OFFSET: .word 0x02 # byte: write 1 to start, reads 0 when done

GPS_X_ANGLE_OFFSET:     .word 0x04 # word: Euler X angle
GPS_Y_ANGLE_OFFSET:     .word 0x08 # word: Euler Y angle
GPS_Z_ANGLE_OFFSET:     .word 0x0C # word: Euler Z angle (Yaw)
GPS_X_COORD_OFFSET:     .word 0x10 # word: X coordinate
GPS_Y_COORD_OFFSET:     .word 0x14 # word: Y coordinate
GPS_Z_COORD_OFFSET:     .word 0x18 # word: Z coordinate

ULTRASONIC_DIST_OFFSET: .word 0x1C # word: Distance in cm, -1 if > 20m

STEERING_OFFSET:        .word 0x20 # byte: Steering (-127 left, 127 right)
MOTOR_OFFSET:           .word 0x21 # byte: Motor (1 fwd, 0 off, -1 back)
HANDBRAKE_OFFSET:       .word 0x22 # byte: Handbrake (1 on, 0 off)

LINE_CAM_DATA_OFFSET:   .word 0x24 # 256-byte array

# Data storage for GPS values (optional, can use registers)
current_x: .word 0
current_y: .word 0
current_yaw: .word 0
# Target parameters (will be used in later steps, good to define them)
TARGET_YAW_DELTA_DEGREES: .word 90 # For a 90 degree right turn. Sign might change.
TARGET_FORWARD_DISTANCE_CM: .word 300 # e.g., 3 meters

# Control Values
MOTOR_FORWARD_VAL:  .byte 1
MOTOR_OFF_VAL:      .byte 0
HANDBRAKE_ON_VAL:   .byte 1
HANDBRAKE_OFF_VAL:  .byte 0
STEER_STRAIGHT_VAL: .byte 0
STEER_MAX_RIGHT_VAL:.byte 127
STEER_MAX_LEFT_VAL: .byte -127
# Example turn values (adjust as needed)
STEER_TURN_RIGHT_CALIBRATED: .byte 45
STEER_TURN_LEFT_CALIBRATED:  .byte -45
YAW_TOLERANCE_DEGREES: .word 5
STEER_TURN_RIGHT_CALIBRATED_VAL: .byte 45
FORWARD_LOOP_ITERATIONS: .word 50 # Calibrate this value!
current_ultrasonic_distance: .word 0
MIN_OBSTACLE_DISTANCE_CM:    .word 30  # Stop if obstacle closer than 30cm

.text
.globl main
main:
    # Prologue: Save ra and any s registers used by main
    addi sp, sp, -16 # Space for ra, s0, s1, s2 (4 words)
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)

    # Load MMIO Base Address into t6.
    # t6 will consistently hold the base MMIO pointer.
    la t5, MMIO_BASE_ADDR   # t5 = address of the MMIO_BASE_ADDR label
    lw t6, 0(t5)            # t6 = actual value stored at MMIO_BASE_ADDR (e.g., 0xFFFF0000)

    # Initialize car state: Handbrake off, motor off, steering straight
    # Registers: t1 for offset, t2 for value to write

    # Release Handbrake
    lw t1, HANDBRAKE_OFFSET     # t1 = value of HANDBRAKE_OFFSET (e.g. 0x22)
    lb t2, HANDBRAKE_OFF_VAL    # t2 = value of HANDBRAKE_OFF_VAL (e.g. 0)
                                # Using lb for byte value, can be lbu if always positive.
    mmio_write_byte t6, t1, t2  # Call macro: mmio_write_byte(t6, offset_from_t1, value_from_t2)

    # Turn Motor Off
    lw t1, MOTOR_OFFSET
    lb t2, MOTOR_OFF_VAL
    mmio_write_byte t6, t1, t2

    # Set Steering Straight
    lw t1, STEERING_OFFSET
    lb t2, STEER_STRAIGHT_VAL
    mmio_write_byte t6, t1, t2

    # --- Program main logic will be inserted here in later steps ---
    # Phase 1: Turning Right (Added Logic)
    # s0 will hold initial_yaw, s1 will hold target_yaw.
    # _get_gps_data is assumed not to clobber s0, s1.

    jal ra, _get_gps_data       # Get initial GPS data, populates current_yaw
    la t0, current_yaw
    lw s0, 0(t0)                # s0 = initial_yaw

    # Calculate target_yaw = (initial_yaw - 90). Adjust if negative.
    # TARGET_YAW_DELTA_DEGREES is 90.
    lw t1, TARGET_YAW_DELTA_DEGREES
    sub s1, s0, t1              # s1 = initial_yaw - 90 (or configured delta)
    bltz s1, _main_adjust_negative_yaw   # If s1 < 0, add 360
_main_adjust_negative_yaw_done:

    # Set car controls for turning
    lw t1, STEERING_OFFSET      # t1 = offset for steering
    lb t2, STEER_TURN_RIGHT_CALIBRATED_VAL # t2 = steering value (e.g., 45)
    mmio_write_byte t6, t1, t2  # Set steering (t6 is MMIO base)

    lw t1, MOTOR_OFFSET         # t1 = offset for motor
    lb t2, MOTOR_FORWARD_VAL    # t2 = motor forward value (1)
    mmio_write_byte t6, t1, t2  # Set motor forward

_main_turn_loop:
    jal ra, _get_gps_data       # Get current GPS data, populates current_yaw
    la t0, current_yaw
    lw t3, 0(t0)                # t3 = current_yaw

    # Check if turn is complete: abs(normalize(current_yaw - target_yaw)) <= tolerance
    sub t4, t3, s1              # t4 = current_yaw (t3) - target_yaw (s1) (this is 'diff')

    # Normalize diff (t4) to be within -180 to 180
_main_normalize_diff_start:
    li t5, 180
    bgt t4, t5, _main_normalize_high     # if diff > 180, diff -= 360
    li t5, -180
    blt t4, t5, _main_normalize_low      # else if diff < -180, diff += 360
    j _main_normalize_end                # else diff is already in -180 to 180 range
_main_normalize_high:
    li t5, 360
    sub t4, t4, t5
    j _main_normalize_end
_main_normalize_low:
    li t5, 360
    add t4, t4, t5
_main_normalize_end:
    # t4 now contains normalized diff

    # Calculate abs(diff) -> store in t5
    move t5, t4                 # t5 = normalized_diff
    bltz t4, _main_abs_diff_negative
    j _main_abs_diff_done
_main_abs_diff_negative:
    sub t5, zero, t4            # t5 = -normalized_diff (making it positive)
_main_abs_diff_done:
    # t5 holds abs(normalized_diff)

    lw t0, YAW_TOLERANCE_DEGREES # t0 = tolerance value (e.g., 5)
    ble t5, t0, _main_turn_complete   # if abs(normalized_diff) <= tolerance, turn is complete

    j _main_turn_loop

_main_turn_complete:
    # Turn complete: straighten steering, motor off (prepares for next phase)
    lw t1, STEERING_OFFSET
    lb t2, STEER_STRAIGHT_VAL
    mmio_write_byte t6, t1, t2  # Set steering straight

    lw t1, MOTOR_OFFSET
    lb t2, MOTOR_OFF_VAL
    mmio_write_byte t6, t1, t2  # Set motor off

    # End of Phase 1. Phase 2 (Moving Forward) will go after this point.
    # Currently, execution will fall through to the existing ecall.

    # Phase 2: Moving Forward (Added Logic)
    # Ensure steering is straight (belt-and-suspenders, or if previous phase didn't guarantee it)
    lw t1, STEERING_OFFSET
    lb t2, STEER_STRAIGHT_VAL
    mmio_write_byte t6, t1, t2  # t6 is MMIO base

    # Set motor to forward
    lw t1, MOTOR_OFFSET
    lb t2, MOTOR_FORWARD_VAL
    mmio_write_byte t6, t1, t2

    # Load loop counter
    la t0, FORWARD_LOOP_ITERATIONS # Get address of the constant
    lw s2, 0(t0)                    # s2 = number of iterations

_main_forward_loop:
    # Get ultrasonic sensor reading
    jal ra, _get_ultrasonic_distance
    la t0, current_ultrasonic_distance
    lw t3, 0(t0)                    # t3 = distance reading from sensor

    # Check if distance is valid (not -1) and if too close to an obstacle
    li t4, -1                       # Load -1 for comparison (no obstacle in 20m range)
    beq t3, t4, _main_no_obstacle_detected # If distance is -1, skip further obstacle checks

    # Obstacle potentially detected (distance is not -1)
    # Check if distance < MIN_OBSTACLE_DISTANCE_CM
    la t0, MIN_OBSTACLE_DISTANCE_CM
    lw t4, 0(t0)                    # t4 = min_allowed_distance (e.g., 30cm)

    # If current_distance (t3) < min_distance (t4), then stop early
    blt t3, t4, _main_forward_complete # Branch to completion if obstacle is too close

_main_no_obstacle_detected:
    # Continue with normal loop decrement if no obstacle caused an early exit
    addi s2, s2, -1                 # s2 is the forward loop counter
    bgtz s2, _main_forward_loop     # If s2 > 0, loop again

    # If s2 reaches 0, fall through to _main_forward_complete
_main_forward_complete:
    # Stop car: motor off, handbrake on
    lw t1, MOTOR_OFFSET
    lb t2, MOTOR_OFF_VAL
    mmio_write_byte t6, t1, t2      # Motor Off

    lw t1, HANDBRAKE_OFFSET
    lb t2, HANDBRAKE_ON_VAL
    mmio_write_byte t6, t1, t2      # Handbrake On

    # End of Phase 2

    # Epilogue: Restore ra and s registers
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    addi sp, sp, 16

# Helper branch target for negative yaw adjustment within main's logic
_main_adjust_negative_yaw:      # This is part of main, not a separate jal subroutine
    addi s1, s1, 360            # s1 += 360
    j _main_adjust_negative_yaw_done

    # Exit program
    li a7, 93 # Syscall number for exit
    li a0, 0  # Exit code 0 (success)
    ecall

#-----------------------------------------------------------------------
# Macro: mmio_write_byte (this is a duplicate, will be removed by the diff)
# Args: base_addr_reg (e.g. t6), offset_val_reg (e.g. t1), byte_val_reg (e.g. t2)
#-----------------------------------------------------------------------
# .macro mmio_write_byte base_addr_reg, offset_val_reg, byte_val_reg
#     add t0, \\base_addr_reg, \\offset_val_reg  # Calculate MMIO address
#     sb \\byte_val_reg, 0(t0)                   # Store byte
# .end_macro

#-----------------------------------------------------------------------
# Macro: mmio_write_word (this is a duplicate, will be removed by the diff)
# Args: base_addr_reg, offset_val_reg, word_val_reg
#-----------------------------------------------------------------------
# .macro mmio_write_word base_addr_reg, offset_val_reg, word_val_reg
#     add t0, \\base_addr_reg, \\offset_val_reg
#     sw \\word_val_reg, 0(t0)
# .end_macro

#-----------------------------------------------------------------------
# Macro: mmio_read_byte_unsigned (this is a duplicate, will be removed by the diff)
# Args: base_addr_reg, offset_val_reg, dest_reg
#-----------------------------------------------------------------------
# .macro mmio_read_byte_unsigned base_addr_reg, offset_val_reg, dest_reg
#     add t0, \\base_addr_reg, \\offset_val_reg
#     lbu \\dest_reg, 0(t0)
# .end_macro

#-----------------------------------------------------------------------
# Macro: mmio_read_byte_signed (this is a duplicate, will be removed by the diff)
# Args: base_addr_reg, offset_val_reg, dest_reg
#-----------------------------------------------------------------------
# .macro mmio_read_byte_signed base_addr_reg, offset_val_reg, dest_reg
#     add t0, \\base_addr_reg, \\offset_val_reg
#     lb \\dest_reg, 0(t0)
# .end_macro

#-----------------------------------------------------------------------
# Macro: mmio_read_word (this is a duplicate, will be removed by the diff)
# Args: base_addr_reg, offset_val_reg, dest_reg
#-----------------------------------------------------------------------
# .macro mmio_read_word base_addr_reg, offset_val_reg, dest_reg
#     add t0, \\base_addr_reg, \\offset_val_reg
#     lw \\dest_reg, 0(t0)
# .end_macro

# main: (this is a duplicate, will be removed by the diff)
    # Load MMIO Base Address into t6.
    # t6 will consistently hold the base MMIO pointer.
    # la t5, MMIO_BASE_ADDR   # t5 = address of the MMIO_BASE_ADDR label
    # lw t6, 0(t5)            # t6 = actual value stored at MMIO_BASE_ADDR (e.g., 0xFFFF0000)

    # Initialize car state: Handbrake off, motor off, steering straight
    # Registers: t1 for offset, t2 for value to write

    # Release Handbrake
    # lw t1, HANDBRAKE_OFFSET     # t1 = value of HANDBRAKE_OFFSET (e.g. 0x22)
    # lb t2, HANDBRAKE_OFF_VAL    # t2 = value of HANDBRAKE_OFF_VAL (e.g. 0)
                                # Using lb for byte value, can be lbu if always positive.
    # mmio_write_byte t6, t1, t2  # Call macro: mmio_write_byte(t6, offset_from_t1, value_from_t2)

    # Turn Motor Off
    # lw t1, MOTOR_OFFSET
    # lb t2, MOTOR_OFF_VAL
    # mmio_write_byte t6, t1, t2

    # Set Steering Straight
    # lw t1, STEERING_OFFSET
    # lb t2, STEER_STRAIGHT_VAL
    # mmio_write_byte t6, t1, t2

    # --- Program main logic will be inserted here in later steps ---
    # Phase 1: Turning Right (Added Logic)
    # s0 will hold initial_yaw, s1 will hold target_yaw.
    # _get_gps_data is assumed not to clobber s0, s1.

    # jal ra, _get_gps_data       # Get initial GPS data, populates current_yaw
    # la t0, current_yaw
    # lw s0, 0(t0)                # s0 = initial_yaw

    # Calculate target_yaw = (initial_yaw - 90). Adjust if negative.
    # TARGET_YAW_DELTA_DEGREES is 90.
    # lw t1, TARGET_YAW_DELTA_DEGREES
    # sub s1, s0, t1              # s1 = initial_yaw - 90 (or configured delta)
    # bltz s1, _main_adjust_negative_yaw   # If s1 < 0, add 360
# _main_adjust_negative_yaw_done:

    # Set car controls for turning
    # lw t1, STEERING_OFFSET      # t1 = offset for steering
    # lb t2, STEER_TURN_RIGHT_CALIBRATED_VAL # t2 = steering value (e.g., 45)
    # mmio_write_byte t6, t1, t2  # Set steering (t6 is MMIO base)

    # lw t1, MOTOR_OFFSET         # t1 = offset for motor
    # lb t2, MOTOR_FORWARD_VAL    # t2 = motor forward value (1)
    # mmio_write_byte t6, t1, t2  # Set motor forward

# _main_turn_loop:
    # jal ra, _get_gps_data       # Get current GPS data, populates current_yaw
    # la t0, current_yaw
    # lw t3, 0(t0)                # t3 = current_yaw

    # Check if turn is complete: abs(normalize(current_yaw - target_yaw)) <= tolerance
    # sub t4, t3, s1              # t4 = current_yaw (t3) - target_yaw (s1) (this is 'diff')

    # Normalize diff (t4) to be within -180 to 180
# _main_normalize_diff_start:
    # li t5, 180
    # bgt t4, t5, _main_normalize_high     # if diff > 180, diff -= 360
    # li t5, -180
    # blt t4, t5, _main_normalize_low      # else if diff < -180, diff += 360
    # j _main_normalize_end                # else diff is already in -180 to 180 range
# _main_normalize_high:
    # li t5, 360
    # sub t4, t4, t5
    # j _main_normalize_end
# _main_normalize_low:
    # li t5, 360
    # add t4, t4, t5
# _main_normalize_end:
    # t4 now contains normalized diff

    # Calculate abs(diff) -> store in t5
    # move t5, t4                 # t5 = normalized_diff
    # bltz t4, _main_abs_diff_negative
    # j _main_abs_diff_done
# _main_abs_diff_negative:
    # sub t5, zero, t4            # t5 = -normalized_diff (making it positive)
# _main_abs_diff_done:
    # t5 holds abs(normalized_diff)

    # lw t0, YAW_TOLERANCE_DEGREES # t0 = tolerance value (e.g., 5)
    # ble t5, t0, _main_turn_complete   # if abs(normalized_diff) <= tolerance, turn is complete

    # j _main_turn_loop

# _main_turn_complete:
    # Turn complete: straighten steering, motor off (prepares for next phase)
    # lw t1, STEERING_OFFSET
    # lb t2, STEER_STRAIGHT_VAL
    # mmio_write_byte t6, t1, t2  # Set steering straight

    # lw t1, MOTOR_OFFSET
    # lb t2, MOTOR_OFF_VAL
    # mmio_write_byte t6, t1, t2  # Set motor off

    # End of Phase 1. Phase 2 (Moving Forward) will go after this point.
    # Currently, execution will fall through to the existing ecall.

# Helper branch target for negative yaw adjustment within main's logic
# _main_adjust_negative_yaw:      # This is part of main, not a separate jal subroutine
    # addi s1, s1, 360            # s1 += 360
    # j _main_adjust_negative_yaw_done

    # Exit program
    # li a7, 93 # Syscall number for exit
    # li a0, 0  # Exit code 0 (success)
    # ecall

#-----------------------------------------------------------------------
# Subroutine: _trigger_mmio_and_wait
# Description: Writes 1 to an MMIO control register and waits for it to become 0.
# Arguments:
#   a0: MMIO base address (e.g., the value loaded into t6)
#   a1: Offset of the control register (e.g., value of GPS_INIT_OFFSET)
# Clobbers: t0, t1, t2. (Caller should save if needed, but simple for now)
# Returns: None
#-----------------------------------------------------------------------
_trigger_mmio_and_wait:
    # Calculate the full MMIO address of the control register
    add t1, a0, a1      # t1 = base_address (from a0) + offset (from a1)

    # Write 1 to the control register to trigger the action
    li t0, 1            # t0 = 1
    sb t0, 0(t1)        # Store byte 1 to address in t1
_wait_loop:
    lbu t2, 0(t1)       # Read byte from control register (unsigned)
    bnez t2, _wait_loop # If t2 is not zero, loop back to _wait_loop
    ret                 # Return to caller

# Placeholder for _get_gps_data and other functions from the plan
_get_gps_data:
    # Prologue: Save ra as we are calling another subroutine (_trigger_mmio_and_wait)
    addi sp, sp, -4
    sw ra, 0(sp)

    # Prepare arguments for _trigger_mmio_and_wait to activate GPS
    # a0 should contain MMIO base address (t6)
    # a1 should contain the offset for the GPS init register
    mv a0, t6                   # MMIO base address is in t6 (set by main)
    lw t1, GPS_INIT_OFFSET      # t1 = value of GPS_INIT_OFFSET (e.g. 0x00)
    mv a1, t1                   # Correct: move offset value to a1
    jal ra, _trigger_mmio_and_wait # Call polling subroutine

    # GPS data is now ready to be read.
    # t6 still holds MMIO base.
    # Use t0 for offset, t1 for read value, t2 for .data address.

    # Read X Coordinate
    lw t0, GPS_X_COORD_OFFSET     # t0 = offset value for X coord
    mmio_read_word t6, t0, t1     # Macro: mmio_read_word(base=t6, offset=t0, dest=t1)
    la t2, current_x              # t2 = address of current_x variable
    sw t1, 0(t2)                  # Store the read X coordinate into current_x

    # Read Y Coordinate
    lw t0, GPS_Y_COORD_OFFSET
    mmio_read_word t6, t0, t1
    la t2, current_y
    sw t1, 0(t2)                  # Store the read Y coordinate into current_y

    # Read Z Angle (Yaw)
    lw t0, GPS_Z_ANGLE_OFFSET
    mmio_read_word t6, t0, t1
    la t2, current_yaw
    sw t1, 0(t2)                  # Store the read Yaw into current_yaw

    # Epilogue: Restore ra
    lw ra, 0(sp)
    addi sp, sp, 4
    ret

_get_ultrasonic_distance:
    # Prologue: Save ra as we are calling _trigger_mmio_and_wait
    addi sp, sp, -4
    sw ra, 0(sp)

    # Prepare arguments for _trigger_mmio_and_wait for Ultrasonic sensor
    # a0 should contain MMIO base address (t6)
    # a1 should contain the offset for the ultrasonic init register
    mv a0, t6                       # MMIO base address is in t6
    lw t1, ULTRASONIC_INIT_OFFSET   # t1 = value of ULTRASONIC_INIT_OFFSET
    mv a1, t1                       # Correctly move offset value to a1 for the call
    jal ra, _trigger_mmio_and_wait  # Call polling subroutine

    # Ultrasonic data is now ready to be read.
    # t6 still holds MMIO base.
    # Use t0 for offset, t1 for read value, t2 for .data address.

    # Read Ultrasonic Distance
    lw t0, ULTRASONIC_DIST_OFFSET     # t0 = offset value for ultrasonic distance
    mmio_read_word t6, t0, t1         # Macro: mmio_read_word(base=t6, offset=t0, dest=t1)
    la t2, current_ultrasonic_distance # t2 = address of current_ultrasonic_distance variable
    sw t1, 0(t2)                      # Store the read distance

    # Epilogue: Restore ra
    lw ra, 0(sp)
    addi sp, sp, 4
    ret

.end
