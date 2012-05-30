# coding: utf-8
module Shotcrawl
  class Lang
    class << self
      def ja
        {
          true:            "有効", 
          false:           "無効",
          autofocus?:      "オートフォーカス",
          disabled?:       "無効化",
          read_only?:      "読取専用",
          required?:       "必須チェック",
          min:             "最小値",
          max:             "最大値",
          length:          "要素数",
          text:            "テキストボックス",
          file:            "ファイルボックス",
          :"select-one"      => "セレクトリスト(one)",
          :"select-multiple" => "セレクトリスト(multi)",
          radio:           "ラジオボタン",
          checkbox:        "チェックボックス",
          button:          "ボタン",
          submit:          "サブミット"
        }
      end
    end
  end
end