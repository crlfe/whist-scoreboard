# Sticky scroll bug

Firefox does not reserve space for the currently-stuck right panel in this
experiment. Unfortunately that means scrolling will never reveal part of the
center panel. A workaround is to add an invisible div to fill that space.
