#!/usr/bin/python

import sys
import runpy

def spy_on_subprocess(event, args):
    # The audit hook for subprocess.run, subprocess.Popen, etc.
    if event == "subprocess.Popen":
        # The hook provides a tuple: (executable, cmd_args, cwd, env)
        # We only care about the cmd_args (the command being spawned)
        _, cmd_args, _, _ = args
        print(f"\n[INTERCEPTED COMMAND]: {cmd_args}\n")

def main():
    # 1. Validate that a target script was provided
    if len(sys.argv) < 2:
        print("Usage: python wrapper.py <target_script.py> [args...]")
        print("Example: python wrapper.py my_script.py --verbose -n 5")
        sys.exit(1)

    # 2. Extract the target script name
    target_script = sys.argv[1]

    # 3. Shift sys.argv to hide the wrapper completely
    # sys.argv changes from: ['wrapper.py', 'target_script.py', '--verbose']
    # to: ['target_script.py', '--verbose']
    sys.argv = sys.argv[1:]

    # 4. Attach the silent listener
    sys.addaudithook(spy_on_subprocess)

    # 5. Execute the target script exactly as if it were run directly
    try:
        runpy.run_path(target_script, run_name="__main__")
    except Exception as e:
        print(f"\n[WRAPPER ERROR] Target script execution failed: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()
