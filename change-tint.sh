#!/bin/bash

# Flexoki Theme Tint Color Changer

set -e

# Current tint color (blue)
CURRENT_TINT="#4385BE"  # blue-400 (for dark theme)

# Available tint colors based on Flexoki palette
declare -A TINT_COLORS=(
    ["red"]="#D14D41"
    ["orange"]="#DA702C"
    ["yellow"]="#D0A215"
    ["green"]="#879A39"
    ["cyan"]="#3AA99F"
    ["blue"]="#4385BE"
    ["purple"]="#8B7EC8"
    ["magenta"]="#CE5D97"
)

# Yaru icon color mappings
declare -A YARU_COLORS=(
    ["red"]="Yaru-red"
    ["orange"]="Yaru-wartybrown"  # Closest match for orange
    ["yellow"]="Yaru-yellow"
    ["green"]="Yaru-olive"  # Using olive as green variant
    ["cyan"]="Yaru-blue"  # Yaru doesn't have cyan, use blue
    ["blue"]="Yaru-blue"
    ["purple"]="Yaru-purple"
    ["magenta"]="Yaru-magenta"
)

# Function to display usage
usage() {
    echo "Usage: $0 [TINT_COLOR] or $0 --list"
    echo ""
    echo "Available tint colors:"
    for color in "${!TINT_COLORS[@]}"; do
        printf "  %-10s %s\n" "$color" "${TINT_COLORS[$color]}"
    done
    echo ""
    echo "Examples:"
    echo "  $0 red      # Change tint to red"
    echo "  $0 purple   # Change tint to purple"
    echo "  $0 --list   # Show available colors"
    echo "  $0 --reset  # Reset to original blue"
}

# Function to list available colors
list_colors() {
    echo "Available Flexoki tint colors:"
    echo ""
    for color in "${!TINT_COLORS[@]}"; do
        printf "  %-10s %s\n" "$color" "${TINT_COLORS[$color]}"
    done
}



# Function to update tint color in files
update_tint() {
    local new_color="$1"
    local color_name="$2"

    echo "Changing tint color to $color_name ($new_color)..."

    # Update btop.theme
    if [ -f "btop.theme" ]; then
        echo "  Updating btop.theme..."
        sed -i "s/theme\[hi_fg\]=\"#[0-9A-Fa-f]\{6\}\"/theme[hi_fg]=\"$new_color\"/g" btop.theme
        sed -i "s/theme\[proc_misc\]=\"#[0-9A-Fa-f]\{6\}\"/theme[proc_misc]=\"$new_color\"/g" btop.theme
    fi

    # Update mako.ini
    if [ -f "mako.ini" ]; then
        echo "  Updating mako.ini..."
        sed -i "s/border-color=#[0-9A-Fa-f]\{6\}/border-color=$new_color/g" mako.ini
    fi

    # Update swayosd.css
    if [ -f "swayosd.css" ]; then
        echo "  Updating swayosd.css..."
        sed -i "s/@define-color border-color #[0-9A-Fa-f]\{6\};/@define-color border-color $new_color;/g" swayosd.css
    fi

    # Update walker.css
    if [ -f "walker.css" ]; then
        echo "  Updating walker.css..."
        sed -i "s/@define-color selected-text #[0-9A-Fa-f]\{6\};/@define-color selected-text $new_color;/g" walker.css
        sed -i "s/@define-color border #[0-9A-Fa-f]\{6\};/@define-color border $new_color;/g" walker.css
    fi

    # Update hyprland.conf
    if [ -f "hyprland.conf" ]; then
        echo "  Updating hyprland.conf..."
        # Remove the # from the color for hyprland (it uses rgba format)
        local hypr_color="${new_color#\#}"
        sed -i "s/col\.active_border = rgba([0-9A-Fa-f]\{6\}ee)/col.active_border = rgba(${hypr_color}ee)/g" hyprland.conf
    fi

    # Update icons.theme
    if [ -f "icons.theme" ]; then
        echo "  Updating icons.theme..."
        local yaru_color="${YARU_COLORS[$color_name]}"
        sed -i "s/Yaru-.*/$yaru_color/" icons.theme
    fi

    echo "✓ Tint color successfully changed to $color_name!"
    echo ""
    echo "Files updated:"
    echo "  - btop.theme (highlight and process misc colors)"
    echo "  - mako.ini (notification border)"
    echo "  - swayosd.css (OSD border)"
    echo "  - walker.css (selected text and border)"
    echo "  - hyprland.conf (active window border)"
    echo "  - icons.theme (Yaru icon color)"
    echo ""
}


# Main script logic
if [ $# -eq 0 ]; then
    usage
    exit 1
fi

case "$1" in
    --help|-h)
        usage
        exit 0
        ;;
    --list|-l)
        list_colors
        exit 0
        ;;
    --reset)
        echo "Resetting tint color to original blue..."
        update_tint "#4385BE" "blue (original)"
        exit 0
        ;;
    *)
        if [ -n "${TINT_COLORS[$1]}" ]; then
            update_tint "${TINT_COLORS[$1]}" "$1"
            exit 0
        else
            echo "Error: Unknown tint color '$1'"
            echo ""
            usage
            exit 1
        fi
        ;;
esac
