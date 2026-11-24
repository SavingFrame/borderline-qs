//@ pragma UseQApplication
import Quickshell
import qs.Bar
import qs.Notifications

Scope {
    NotificationService { id: notifications }

    Bar { notificationService: notifications }
    NotificationToasts { service: notifications }
}
