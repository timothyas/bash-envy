#!/bin/bash

# --- Lines to be modified
#prefix="anemoi-house/gfs/1.00deg/mse06h/experiments"
#prefix="anemoi-house/gfs/0.25deg/mse06h/experiments"
#prefix="nested-eagle/1.00deg-15km/mse06h/experiments"
#prefix="nested-eagle/1.00deg-15km/mse24h/experiments"
#prefix="nested-eagle/1.00deg-15km/crps06h/experiments"
#prefix="nested-eagle/0.25deg-06km/mse06h/experiments"
#prefix="nested-eagle/0.25deg-06km/mse24h/experiments"

# TODO:
#prefix="nested-eagle/0.25deg-06km/production

# --- The rest is automated

# Ensure required environment variables are set
if [[ -z "$COMMUNITY" ]]; then
    echo "Error: \$COMMUNITY environment variable is not set."
    exit 1
fi

if [[ -z "$SCRATCH" ]]; then
    echo "Error: \$SCRATCH environment variable is not set."
    exit 1
fi

search_dir="${SCRATCH}/${prefix}"

# Verify the root search directory exists before starting
if [[ ! -d "$search_dir" ]]; then
    echo "Error: Search directory '$search_dir' does not exist."
    exit 1
fi

echo "Searching for checkpoint directories in: $search_dir"

# Temporarily enable nullglob so unmatched wildcards don't execute the loop
shopt -s nullglob

# Look exactly two levels deep for 'checkpoint' directories
for ckpt_dir in "$search_dir"/*/*/checkpoint; do
    
    # Guard to ensure it is actually a directory
    [[ -d "$ckpt_dir" ]] || continue

    # Extract the base_dir (e.g., "0.5deg-latent/win17280")
    # 1. Remove the root search directory path from the front
    rel_path="${ckpt_dir#$search_dir/}"
    # 2. Remove the "/checkpoint" string from the end
    base_dir="${rel_path%/checkpoint}"

    echo "------------------------------------------------"
    echo "Processing: $base_dir"

    # Loop through the unique identifier subdirectories
    for uuid_dir in "$ckpt_dir"/*/; do
        
        # Guard against empty directories
        [[ -d "$uuid_dir" ]] || continue

        # Extract just the UUID
        uuid_dir="${uuid_dir%/}"
        uuid="${uuid_dir##*/}"

        # Find the checkpoint files
        ckpt_files=("$uuid_dir"/*last.ckpt)

        # If we found one or more *last.ckpt files, proceed with the copy
        if [[ ${#ckpt_files[@]} -gt 0 ]]; then
            
            # Construct the full target directory path
            target_dir="${COMMUNITY}/${prefix}/${base_dir}/checkpoint/${uuid}"

            # Create the target directory structure
            mkdir -p "$target_dir"

            # Copy the files
            for ckpt in "${ckpt_files[@]}"; do
                echo "  -> Copying: $(basename "$ckpt") to $target_dir/"
                cp "$ckpt" "$target_dir/"
            done
            
        else
            echo "  -> Info: No *last.ckpt files found in UUID '$uuid'. Skipping."
        fi
    done
done

# Turn off nullglob
shopt -u nullglob

echo "------------------------------------------------"
echo "Copy operation complete!"
