# White Label Widgets

This directory contains reusable UI widgets for the white-label modules.

## Structure

```
widgets/
├── runtime/       # Client-facing widgets (for end users)
├── admin/         # Admin/configuration widgets (for restaurant owners)
└── common/        # Shared widgets used by both runtime and admin
```

## Purpose

Module-specific UI widgets should be placed here rather than in the Builder blocks.
The Builder should focus on visual content blocks (hero, banner, text, etc.),
while module functionality is configured through the white-label system and
rendered using these widgets.

## Guidelines

- **Runtime widgets**: User-facing components (e.g., loyalty card display, click & collect selector)
- **Admin widgets**: Configuration screens for restaurant owners
- **Common widgets**: Shared components like cards, lists, forms used by modules

## Migration Plan

Module UI widgets from various locations will be progressively moved here for better organization:
- Click & Collect point selector → runtime/
- Payment admin settings → admin/
- Newsletter subscription form → runtime/
- Kitchen tablet WebSocket UI → runtime/
