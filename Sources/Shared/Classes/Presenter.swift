import Foundation
import CoreGraphics

protocol AnyPresenter {
  func configure(view: View, model: ItemCodable, containerSize: CGSize) -> CGSize
  func encode<T: KeyedEncodingContainerProtocol>(model: ItemCodable,
                                                 forKey key: T.Key,
                                                 container: inout T) throws
  func decode<T: KeyedDecodingContainerProtocol>(from container: T,
                                                 forKey key: T.Key) throws -> ItemCodable?
}

public class Presenter<T: View, U: ItemModel>: AnyPresenter {
  public typealias ConfigurationClosure = ((_ view: T, _ model: U, _ containerSize: CGSize) -> CGSize)
  let identifier: StringConvertible
  private let closure: ConfigurationClosure

  public init(identifier: StringConvertible, _ closure: @escaping ConfigurationClosure) {
    self.identifier = identifier
    self.closure = closure
  }

  func configure(view: View, model: ItemCodable, containerSize: CGSize) -> CGSize {
    guard let view = view as? T else {
      return .zero
    }

    guard let model = model as? U else {
      return .zero
    }

    return closure(view, model, containerSize)
  }

  func encode<T: KeyedEncodingContainerProtocol>(model: ItemCodable,
                                                 forKey key: T.Key,
                                                 container: inout T) throws {
    try container.encodeIfPresent(model as? U, forKey: key)
  }

  func decode<T: KeyedDecodingContainerProtocol>(from container: T,
                                                 forKey key: T.Key) throws -> ItemCodable? {
    return try container.decodeIfPresent(U.self, forKey: key)
  }
}
