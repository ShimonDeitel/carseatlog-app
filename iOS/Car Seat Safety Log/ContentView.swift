import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: Store
    @EnvironmentObject var purchases: PurchaseManager

    @State private var showingAdd = false
    @State private var showingSettings = false
    @State private var showingPaywall = false
    @State private var newTitle = ""
    @State private var newDetail = ""
    @State private var editingItem: CarSeat?

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()
                if store.items.isEmpty {
                    ContentUnavailableView("No entries yet", systemImage: "list.bullet.clipboard", description: Text("Tap + to add your first entry."))
                } else {
                    List {
                        ForEach(store.items) { item in
                            Button {
                                editingItem = item
                            } label: {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(item.title).font(Theme.headlineFont).foregroundStyle(Theme.textPrimary)
                                        if !item.detail.isEmpty {
                                            Text(item.detail).font(Theme.captionFont).foregroundStyle(Theme.textSecondary)
                                        }
                                    }
                                    Spacer()
                                    Image(systemName: item.isDone ? "checkmark.circle.fill" : "circle")
                                        .foregroundStyle(item.isDone ? Theme.accent : Theme.textSecondary)
                                        .onTapGesture { store.toggleDone(item) }
                                }
                            }
                            .accessibilityIdentifier("row_\(item.title)")
                            .listRowBackground(Theme.surface)
                        }
                        .onDelete { offsets in store.delete(at: offsets) }
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("Car Seat Safety Log")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                    }
                    .accessibilityIdentifier("settingsButton")
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        if store.canAdd(isPro: purchases.isPro) {
                            showingAdd = true
                        } else {
                            showingPaywall = true
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                    .accessibilityIdentifier("addButton")
                }
            }
            .sheet(isPresented: $showingAdd) {
                addSheet
            }
            .sheet(item: $editingItem) { item in
                editSheet(for: item)
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
            }
        }
        .tint(Theme.accent)
    }

    private var addSheet: some View {
        NavigationStack {
            Form {
                TextField("Title", text: $newTitle)
                    .accessibilityIdentifier("titleField")
                TextField("Detail", text: $newDetail)
                    .accessibilityIdentifier("detailField")
            }
            .navigationTitle("New Entry")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        showingAdd = false
                        newTitle = ""
                        newDetail = ""
                    }
                    .accessibilityIdentifier("cancelAddButton")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        guard !newTitle.trimmingCharacters(in: .whitespaces).isEmpty else { return }
                        store.add(title: newTitle, detail: newDetail)
                        newTitle = ""
                        newDetail = ""
                        showingAdd = false
                    }
                    .accessibilityIdentifier("saveAddButton")
                }
            }
            .onTapGesture {
                hideKeyboard()
            }
        }
    }

    private func editSheet(for item: CarSeat) -> some View {
        EditItemView(item: item) { updated in
            store.update(updated)
        } onDelete: {
            store.delete(item)
        }
    }
}

struct EditItemView: View {
    @Environment(\.dismiss) private var dismiss
    @State var item: CarSeat
    var onSave: (CarSeat) -> Void
    var onDelete: () -> Void

    var body: some View {
        NavigationStack {
            Form {
                TextField("Title", text: $item.title)
                    .accessibilityIdentifier("editTitleField")
                TextField("Detail", text: $item.detail)
                    .accessibilityIdentifier("editDetailField")
                Button("Delete Entry", role: .destructive) {
                    onDelete()
                    dismiss()
                }
                .accessibilityIdentifier("deleteEntryButton")
            }
            .navigationTitle("Edit Entry")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        onSave(item)
                        dismiss()
                    }
                    .accessibilityIdentifier("saveEditButton")
                }
            }
            .onTapGesture {
                hideKeyboard()
            }
        }
    }
}

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
