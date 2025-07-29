import Tokenizer

enum ProcessResult: ~Copyable {
    case done
    case reprocess(Token)
}
