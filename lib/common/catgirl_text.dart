final class _CatgirlTone {
  const _CatgirlTone({
    required this.joiner,
    required this.endings,
    required this.exclamations,
    required this.questions,
  });

  final String joiner;

  final List<String> endings;

  final List<String> exclamations;

  final List<String> questions;
}

const _jaTone = _CatgirlTone(
  joiner: '',
  endings: ['にゃ〜', 'にゃん〜', 'にゃ〜にゃ'],
  exclamations: ['にゃ！', 'にゃん！'],
  questions: ['にゃ？', 'にゃん？'],
);

const _koTone = _CatgirlTone(
  joiner: '',
  endings: ['냥~', '냥냥~', '냥~ 냥~'],
  exclamations: ['냥!', '냥냥!'],
  questions: ['냥?', '냥냥?'],
);

const _ruTone = _CatgirlTone(
  joiner: ' ',
  endings: ['ня~', 'ня-ня~', 'ня~ ня~'],
  exclamations: ['ня!', 'ня-ня!'],
  questions: ['ня?', 'ня-ня?'],
);

const _latinTone = _CatgirlTone(
  joiner: ' ',
  endings: ['nya~', 'nyaa~', 'nya~ nya~'],
  exclamations: ['nya!', 'nyaa!'],
  questions: ['nya?', 'nyaa?'],
);

/// Chinese copy is rewritten through this persona catalogue before the
/// ending is picked, so the mode reads like a catgirl rather than a suffix.
const _zhPhrases = <String, String>{
  '配置文件': '小鱼干档案',
  '运行中': '撒欢中',
  '已连接': '爪子牵上了',
  '未连接': '还没牵爪',
  '服务器': '猫窝服务器',
  '订阅': '小鱼干订阅',
  '设置': '猫窝设置',
  '网络': '网线球',
  '连接': '牵爪',
  '代理': '替身娃娃',
  '节点': '小鱼干节点',
  '延迟': '反应速度',
  '测试': '挠挠测',
  '更新': '换新',
  '下载': '叼回来',
  '上传': '送出去',
  '启动': '迈爪开动',
  '停止': '蜷起来歇会',
  '失败': '翻车',
  '成功': '顺毛成功',
  '错误': '爪滑了',
  '警告': '炸毛提醒',
  '删除': '丢掉',
  '保存': '收好',
  '添加': '叼回来',
  '导入': '搬进来',
  '导出': '搬出去',
  '关于': '猫猫小秘密',
  '工具': '百宝袋',
  '背景': '爪印墙',
  '亮度': '灯光',
  '模糊': '雾气',
  '通知': '喵叫',
  '语言': '猫语',
  '主题': '毛色',
  '默认': '老规矩',
  '启用': '打开爪爪',
  '关闭': '收起爪爪',
  '点击': '戳戳',
  '选择': '挑挑',
  '输入': '敲敲',
  '确认': '说好了哦',
  '取消': '算啦',
  '请': '拜托啦',
  '你': '主人',
};

const _zhEndings = ['喵～', '喵呜～', '了呢喵～', '～喵'];

const _zhShortEndings = ['喵', '喵～', '喵呜', '喵！'];

const _zhExclamations = ['喵！', '喵呜！'];

const _zhQuestions = ['喵？', '喵呜？'];

const _zhOpeners = ['诶嘿～', '悄悄说，', '猫猫告诉你，'];

/// Kaomoji added to long Chinese copy. Emoji are not allowed here.
const _zhKaomoji = ['(ฅ^•ﻌ•^ฅ)', '(｡•ω•｡)', '(＝^･ω･^＝)', '(๑•̀ω•́)ノ'];

const _zhSentenceLength = 10;

const _zhOpenLength = 14;

const _zhKaomojiLength = 20;

const _tokensKeptAsIs = {
  '%',
  'ms',
  'dB',
  'MB',
  'GB',
  'KB',
  'TB',
  'B',
  'MB/s',
  'KB/s',
  'seconds',
  'minutes',
  'hours',
  'days',
  'IPv4',
  'IPv6',
  'IP',
  'URL',
  'URLs',
  'API',
  'TUN',
  'VPN',
  'N/A',
};

final _letterPattern = RegExp(
  r'[A-Za-z\u00C0-\u024F\u0400-\u04FF\u3040-\u30FF\u4E00-\u9FFF\uAC00-\uD7AF]',
);

final _catgirlMarkPattern = RegExp(
  r'(?:喵|にゃ|냥|ня|nya)[~〜～！!？?。]?$|[~〜～]$',
  caseSensitive: false,
);

final _urlPattern = RegExp(r'^(?:[A-Za-z][A-Za-z0-9+.\-]*://|www\.)\S+$');

final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

final _domainPattern = RegExp(
  r'^(?:[A-Za-z0-9](?:[A-Za-z0-9\-]*[A-Za-z0-9])?\.)+[A-Za-z]{2,}$',
);

final _acronymPattern = RegExp(r'^[A-Z][A-Z0-9]*(?:[-_/][A-Z0-9]+)*$');

/// Copy that ends in a separator is a fragment of a larger line, not a line.
final _fragmentEndingPattern = RegExp(r'[:：/>（(—–\-]$');

enum _CatgirlLanguage { zh, ja, ko, ru, latin }

/// Rewrites [text] in the catgirl style of [locale].
///
/// Data-only tokens, fragments of a larger line and copy that already ends in
/// an ending are returned unchanged, so at most one ending is ever added.
String catgirlize(String text, String locale) {
  if (text.isEmpty) return text;
  final trimmed = text.trim();
  if (trimmed.isEmpty) return text;
  if (trimmed != text) return text;
  if (_isKeptAsIs(trimmed)) return text;
  return switch (_languageOf(locale)) {
    _CatgirlLanguage.zh => _catgirlizeZh(trimmed),
    _CatgirlLanguage.ja => _catgirlizeTone(trimmed, _jaTone),
    _CatgirlLanguage.ko => _catgirlizeTone(trimmed, _koTone),
    _CatgirlLanguage.ru => _catgirlizeTone(trimmed, _ruTone),
    _CatgirlLanguage.latin => _catgirlizeTone(trimmed, _latinTone),
  };
}

bool _isKeptAsIs(String text) {
  if (_fragmentEndingPattern.hasMatch(text)) return true;
  if (_catgirlMarkPattern.hasMatch(text)) return true;
  if (_zhKaomoji.any(text.endsWith)) return true;
  if (text.runes.length <= 1) return true;
  if (_tokensKeptAsIs.contains(text)) return true;
  if (!_letterPattern.hasMatch(text)) return true;
  if (_urlPattern.hasMatch(text)) return true;
  if (_emailPattern.hasMatch(text)) return true;
  if (_domainPattern.hasMatch(text)) return true;
  if (_acronymPattern.hasMatch(text)) return true;
  return false;
}

_CatgirlLanguage _languageOf(String locale) {
  final code = locale.replaceAll('-', '_').split('_').first.toLowerCase();
  return switch (code) {
    'zh' => _CatgirlLanguage.zh,
    'ja' => _CatgirlLanguage.ja,
    'ko' => _CatgirlLanguage.ko,
    'ru' => _CatgirlLanguage.ru,
    _ => _CatgirlLanguage.latin,
  };
}

int _seedOf(String text) {
  var seed = 7;
  for (final rune in text.runes) {
    seed = (seed * 31 + rune) % 100000007;
  }
  return seed;
}

String _pick(List<String> values, int seed) => values[seed % values.length];

String _applyZhPhrases(String text) {
  var result = text;
  for (final entry in _zhPhrases.entries) {
    result = result.replaceAll(entry.key, entry.value);
  }
  return result;
}

String _catgirlizeZh(String text) {
  final body = _applyZhPhrases(text);
  final length = text.runes.length;
  final seed = _seedOf(text);
  final last = body[body.length - 1];
  final String marked;
  switch (last) {
    case '。':
      marked =
          '${body.substring(0, body.length - 1)}${_pick(_zhEndings, seed)}';
    case '！':
      marked =
          '${body.substring(0, body.length - 1)}${_pick(_zhExclamations, seed)}';
    case '？':
      marked =
          '${body.substring(0, body.length - 1)}${_pick(_zhQuestions, seed)}';
    default:
      marked =
          '$body${_pick(length >= _zhSentenceLength ? _zhEndings : _zhShortEndings, seed)}';
  }
  var result = marked;
  if (length >= _zhKaomojiLength) {
    result = '$marked ${_pick(_zhKaomoji, seed)}';
  } else if (length >= _zhOpenLength && seed.isEven) {
    result = '${_pick(_zhOpeners, seed)}$marked';
  }
  return result;
}

String _catgirlizeTone(String text, _CatgirlTone tone) {
  final seed = _seedOf(text);
  final body = text.substring(0, text.length - 1);
  return switch (text[text.length - 1]) {
    '。' || '.' => '$body${tone.joiner}${_pick(tone.endings, seed)}',
    '！' || '!' => '$body${tone.joiner}${_pick(tone.exclamations, seed)}',
    '？' || '?' => '$body${tone.joiner}${_pick(tone.questions, seed)}',
    _ => '$text${tone.joiner}${_pick(tone.endings, seed)}',
  };
}
