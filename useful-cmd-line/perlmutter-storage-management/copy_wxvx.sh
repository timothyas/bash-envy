#!/bin/bash

# --- Lines to be modified
#prefix="anemoi-house/gfs/1.00-degree/mse06h/experiments"
#prefix="anemoi-house/gfs/0.25-degree/mse06h/experiments"
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

echo "Searching for obs-val directories in: $search_dir"

# Temporarily enable nullglob so unmatched wildcards don't execute the loop
shopt -s nullglob

# Add the asterisk to match 'obs-val', 'obs-val-global', etc.
for val_dir in "$search_dir"/*/*/inference-validation/obs-val*; do

    # Guard to ensure it is actually a directory
    [[ -d "$val_dir" ]] || continue

    # Extract the relative path (e.g., "0.5deg-latent/win17280/inference-validation/obs-val-global")
    rel_path="${val_dir#$search_dir/}"

    # Extract the clean base_dir for your logging by stripping from "/inference-validation" onwards
    base_dir="${rel_path%%/inference-validation*}"

    echo "------------------------------------------------"
    echo "Processing: $base_dir -> $(basename "$val_dir")"

    # Gather .nc files safely
    nc_files=("$val_dir"/*.nc)

    # Only attempt to create directories and copy if files exist
    if [[ ${#nc_files[@]} -gt 0 ]]; then

        # Construct the full target directory path mirroring the relative structure perfectly
        target_dir="${COMMUNITY}/${prefix}/${rel_path}"

        # Create the target directory structure
        mkdir -p "$target_dir"

        # Copy the files
        echo "  -> Copying ${#nc_files[@]} .nc file(s) to $target_dir/"
        cp "${nc_files[@]}" "$target_dir/"
    else
        echo "  -> Info: No .nc files found in '$val_dir'. Skipping."
    fi

done

# Turn off nullglob
shopt -u nullglob

echo "------------------------------------------------"
echo "Copy operation complete!"
