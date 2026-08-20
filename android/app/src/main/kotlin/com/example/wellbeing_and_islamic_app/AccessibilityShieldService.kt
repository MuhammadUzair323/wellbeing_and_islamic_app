package com.example.wellbeing_and_islamic_app

import android.accessibilityservice.AccessibilityService
import android.view.accessibility.AccessibilityEvent

/**
 * Placeholder service for future native focus-shield accessibility controls.
 */
class AccessibilityShieldService : AccessibilityService() {
    override fun onAccessibilityEvent(event: AccessibilityEvent?) = Unit

    override fun onInterrupt() = Unit
}
