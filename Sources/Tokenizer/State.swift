// Reference: https://html.spec.whatwg.org/multipage/parsing.html#tokenization
enum State {
    case data
    case rcdata
    case rawtext
    case scriptData
    case plaintext
    case tagOpen
    case endTagOpen
    case tagName
    case rcdataLessThanSign
    case rcdataEndTagOpen
    case rcdataEndTagName
    case rawtextLessThanSign
    case rawtextEndTagOpen
    case rawtextEndTagName
    case scriptDatalessThanSign
    case scriptDataEndTagOpen
    case scriptDataEndTagName
    case scriptDataEscapeStart
    case scriptDataEscapeStartDash
    case scriptDataEscaped
    case scriptDataEscapedDash
    case scriptDataEscapedDashDash
    case scriptDataEscapedLessThanSign
    case scriptDataEscapedEndTagOpen
    case scriptDataEscapedEndTagName
    case scriptDataDoubleEscapeStart
    case scriptDataDoubleEscaped
    case scriptDataDoubleEscapedDash
    case scriptDataDoubleEscapedDashDash
    case scriptDataDoubleEscapedLessThanSign
    case scriptDataDoubleEscapeEnd
    case beforeAttributeName
    case attributeName
    case afterAttributeName
    case beforeAttributeValue
    case attributeValueDoubleQuoted
    case attributeValueSingleQuoted
    case attributeValueUnquoted
    case afterAttributeValueQuoted
    case selfClosingStartTag
    case bogusComment
    case markupDeclarationOpen
    case commentStart
    case commentStartDash
    case comment
    case commentLessThanSign
    case commentLessThanSignBang
    case commentLessThanSignBangDash
    case commentLessThanSignBangDashDash
    case commentEndDash
    case commentEnd
    case commentEndBang
    case doctype
    case beforeDOCTYPEName
    case doctypeName
    case afterDOCTYPEName
    case afterDOCTYPEPublicKeyword
    case beforeDOCTYPEPublicID
    case doctypePublicIDDoubleQuoted
    case doctypePublicIDSingleQuoted
    case afterDOCTYPEPublicID
    case betweenDOCTYPEPublicAndSystemIDs
    case afterDOCTYPESystemKeyword
    case beforeDOCTYPESystemID
    case doctypeSystemIDDoubleQuoted
    case doctypeSystemIDSingleQuoted
    case afterDOCTYPESystemID
    case bogusDOCTYPE
    case cdataSection
    case cdataSectionBracket
    case cdataSectionEnd
    // case characterReference
    // case namedCharacterReference
    // case ambiguousAmpersand
    // case numericCharacterReference
    // case hexadecimalCharacterReferenceStart
    // case decimalCharacterReferenceStart
    // case hexadecimalCharacterReference
    // case decimalCharacterReference
    // case numericCharacterReferenceEnd
}
