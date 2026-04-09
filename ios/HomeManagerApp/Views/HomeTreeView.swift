import SwiftUI

struct HomeTreeView: View {
    @StateObject private var viewModel: HomeViewModel

    init() {
        let store = HomeStore()
        _viewModel = StateObject(wrappedValue: HomeViewModel(store: store))
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                BreadcrumbView(nodes: viewModel.currentBreadcrumb) { space in
                    viewModel.goToSpace(space.id)
                }

                TextField("搜索空间或物品", text: $viewModel.searchText)
                    .textFieldStyle(.roundedBorder)

                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        if viewModel.isSearching {
                            SearchResultSection(
                                spaces: viewModel.searchSpaces,
                                items: viewModel.searchItems,
                                onTapSpace: { viewModel.goToSpace($0.id) },
                                onDeleteSpace: { viewModel.deleteSpace($0.id) },
                                onDeleteItem: { viewModel.deleteItem($0.id) }
                            )
                        } else {
                            if !viewModel.childSpaces.isEmpty {
                                Text("子空间")
                                    .font(.headline)
                                LazyVGrid(columns: [GridItem(.adaptive(minimum: 120))], spacing: 12) {
                                    ForEach(viewModel.childSpaces) { space in
                                        Button {
                                            viewModel.goToSpace(space.id)
                                        } label: {
                                            VStack(spacing: 8) {
                                                Image(systemName: space.icon)
                                                    .font(.title2)
                                                Text(space.name)
                                                    .font(.subheadline)
                                                    .lineLimit(1)
                                            }
                                            .frame(maxWidth: .infinity, minHeight: 96)
                                            .background(Color(.secondarySystemBackground))
                                            .clipShape(RoundedRectangle(cornerRadius: 12))
                                        }
                                        .buttonStyle(.plain)
                                        .contextMenu {
                                            Button(role: .destructive) {
                                                viewModel.deleteSpace(space.id)
                                            } label: {
                                                Label("删除空间", systemImage: "trash")
                                            }
                                        }
                                    }
                                }
                            }

                            Text("物品")
                                .font(.headline)
                            ForEach(viewModel.currentItems) { item in
                                NavigationLink {
                                    ItemDetailView(
                                        item: item,
                                        onDelete: { viewModel.deleteItem(item.id) },
                                        onIncrease: { viewModel.incrementItem(item.id, current: item.quantity) }
                                    )
                                } label: {
                                    HStack {
                                        Image(systemName: "shippingbox")
                                        Text(item.name)
                                        Spacer()
                                        Text("x\(item.quantity)")
                                            .foregroundStyle(.secondary)
                                    }
                                    .padding(.vertical, 4)
                                }
                            }
                        }
                    }
                }

                CreatePanel(
                    newSpaceName: $viewModel.newSpaceName,
                    newItemName: $viewModel.newItemName,
                    createSpace: viewModel.createSpace,
                    createItem: viewModel.createItem
                )
            }
            .padding()
            .navigationTitle("全屋管理")
        }
    }
}

private struct BreadcrumbView: View {
    let nodes: [SpaceNode]
    let onTap: (SpaceNode) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                ForEach(Array(nodes.enumerated()), id: \.element.id) { index, node in
                    if index > 0 {
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Button(node.name) {
                        onTap(node)
                    }
                    .buttonStyle(.borderless)
                }
            }
        }
    }
}

private struct SearchResultSection: View {
    let spaces: [SpaceNode]
    let items: [ItemNode]
    let onTapSpace: (SpaceNode) -> Void
    let onDeleteSpace: (SpaceNode) -> Void
    let onDeleteItem: (ItemNode) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("搜索结果")
                .font(.headline)

            if spaces.isEmpty && items.isEmpty {
                Text("无匹配结果")
                    .foregroundStyle(.secondary)
            }

            ForEach(spaces) { space in
                HStack {
                    Image(systemName: space.icon)
                    Text(space.name)
                    Spacer()
                    Button("进入") {
                        onTapSpace(space)
                    }
                    .buttonStyle(.bordered)
                    Button(role: .destructive) {
                        onDeleteSpace(space)
                    } label: {
                        Image(systemName: "trash")
                    }
                    .buttonStyle(.borderless)
                }
            }

            ForEach(items) { item in
                HStack {
                    Image(systemName: "shippingbox")
                    Text(item.name)
                    Spacer()
                    Text("x\(item.quantity)")
                    Button(role: .destructive) {
                        onDeleteItem(item)
                    } label: {
                        Image(systemName: "trash")
                    }
                    .buttonStyle(.borderless)
                }
            }
        }
    }
}

private struct CreatePanel: View {
    @Binding var newSpaceName: String
    @Binding var newItemName: String

    let createSpace: () -> Void
    let createItem: () -> Void

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                TextField("新增子空间", text: $newSpaceName)
                    .textFieldStyle(.roundedBorder)
                Button("添加", action: createSpace)
                    .buttonStyle(.borderedProminent)
            }
            HStack {
                TextField("新增物品", text: $newItemName)
                    .textFieldStyle(.roundedBorder)
                Button("添加", action: createItem)
                    .buttonStyle(.bordered)
            }
        }
    }
}
