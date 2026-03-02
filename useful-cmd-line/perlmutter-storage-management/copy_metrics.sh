#!/bin/bash

# --- Lines to be modified
#prefix="anemoi-house/gfs/1.00-degree/mse06h/experiments"
#prefix="anemoi-house/gfs/0.25-degree/mse06h/experiments"
#prefix="nested-eagle/1.00deg-15km/mse06h/experiments"
#prefix="nested-eagle/1.00deg-15km/mse24h/experiments"
#prefix="nested-eagle/0.25deg-06km/mse06h/experiments"
#prefix="nested-eagle/0.25deg-06km/mse24h/experiments"

prefix="nested-eagle/1.00deg-15km/crps06h/experiments"

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

# Define the metrics to look for
METRICS=("rmse" "mae" "spatial" "spectra" "fcrps" "spread")

# Verify the root search directory exists before starting
if [[ ! -d "$search_dir" ]]; then
    echo "Error: Search directory '$search_dir' does not exist."
    exit 1
fi

echo "Searching for inference-validation directories in: $search_dir"

# Temporarily enable nullglob so unmatched wildcards don't execute the loop
shopt -s nullglob

# Look exactly two levels deep for 'inference-validation' directories
for val_dir in "$search_dir"/*/*/inference-validation; do
    
    # Guard to ensure it is actually a directory
    [[ -d "$val_dir" ]] || continue

    # Extract the base_dir (e.g., "0.5deg-latent/win17280")
    # 1. Remove the root search directory path from the front
    rel_path="${val_dir#$search_dir/}"
    # 2. Remove the "/inference-validation" string from the end
    base_dir="${rel_path%/inference-validation}"

    echo "------------------------------------------------"
    echo "Processing: $base_dir"

    # Collect all matching NetCDF files for the defined metrics
    nc_files=()
    for metric in "${METRICS[@]}"; do
        # This appends any matching files to our array
        nc_files+=("$val_dir"/${metric}*.nc)
    done

    # If we found one or more matching files, proceed with the copy
    if [[ ${#nc_files[@]} -gt 0 ]]; then
        
        # Construct the full target directory path
        target_dir="${COMMUNITY}/${prefix}/${base_dir}/inference-validation"

        # Create the target directory structure
        mkdir -p "$target_dir"

        # Copy the files
        for nc_file in "${nc_files[@]}"; do
            echo "  -> Copying: $(basename "$nc_file") to $target_dir/"
            cp "$nc_file" "$target_dir/"
        done
        
    else
        echo "  -> Info: No matching metric .nc files found in UUID '$uuid'. Skipping."
    fi
done

# Turn off nullglob
shopt -u nullglob

echo "------------------------------------------------"
echo "Copy operation complete!"
