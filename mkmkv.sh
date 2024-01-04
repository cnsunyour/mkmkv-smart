#!/usr/local/bin/bash

# 检查是否安装了 mkvmerge
# 如果没有安装，退出脚本
if ! command -v mkvmerge &>/dev/null; then
  echo "mkvmerge not found, please install mkvtoolnix"
  exit
fi

# 所有语言代码和语言名称的映射
declare -A lang_map=(
  ["af"]="Afrikaans"
  ["af-ZA"]="Afrikaans (South Africa)"
  ["am"]="አማርኛ"
  ["am-ET"]="አማርኛ (ኢትዮጵያ)"
  ["ar"]="العربية"
  ["ar-001"]="العربية"
  ["ar-AR"]="العربية"
  ["ar-AE"]="العربية (الإمارات العربية المتحدة)"
  ["ar-BH"]="العربية (البحرين)"
  ["ar-DZ"]="العربية (الجزائر)"
  ["ar-EG"]="العربية (مصر)"
  ["ar-IQ"]="العربية (العراق)"
  ["ar-JO"]="العربية (الأردن)"
  ["ar-KW"]="العربية (الكويت)"
  ["ar-LB"]="العربية (لبنان)"
  ["ar-LY"]="العربية (ليبيا)"
  ["ar-MA"]="العربية (المغرب)"
  ["ar-OM"]="العربية (عمان)"
  ["ar-QA"]="العربية (قطر)"
  ["ar-SA"]="العربية (المملكة العربية السعودية)"
  ["ar-SY"]="العربية (سوريا)"
  ["ar-TN"]="العربية (تونس)"
  ["ar-YE"]="العربية (اليمن)"
  ["az"]="Azərbaycan dili"
  ["az-AZ"]="Azərbaycan dili (Azərbaycan)"
  ["be"]="Беларуская"
  ["be-BY"]="Беларуская (Беларусь)"
  ["bg"]="български"
  ["bg-BG"]="български (България)"
  ["bn"]="বাংলা"
  ["bn-BD"]="বাংলা (বাংলাদেশ)"
  ["bn-IN"]="বাংলা (ভারত)"
  ["bs"]="Bosanski"
  ["bs-BA"]="Bosanski (Bosna i Hercegovina)"
  ["ca"]="Català"
  ["ca-ES"]="Català (Espanya)"
  ["cs"]="čeština"
  ["cs-CZ"]="čeština (Česká republika)"
  ["cy"]="Cymraeg"
  ["cy-GB"]="Cymraeg (y Deyrnas Unedig)"
  ["da"]="dansk"
  ["da-DK"]="dansk (Danmark)"
  ["de"]="Deutsch"
  ["de-AT"]="Deutsch (Österreich)"
  ["de-CH"]="Deutsch (Schweiz)"
  ["de-DE"]="Deutsch (Deutschland)"
  ["de-LI"]="Deutsch (Liechtenstein)"
  ["de-LU"]="Deutsch (Luxemburg)"
  ["dv"]="ދިވެހިބަސް"
  ["dv-MV"]="ދިވެހިބަސް (Maldives)"
  ["el"]="Ελληνικά"
  ["el-GR"]="Ελληνικά (Ελλάδα)"
  ["en"]="English"
  ["en-AU"]="English (Australia)"
  ["en-BZ"]="English (Belize)"
  ["en-CA"]="English (Canada)"
  ["en-CB"]="English (Caribbean)"
  ["en-GB"]="English (United Kingdom)"
  ["en-IE"]="English (Ireland)"
  ["en-IN"]="English (India)"
  ["en-JM"]="English (Jamaica)"
  ["en-NG"]="English (Nigeria)"
  ["en-NZ"]="English (New Zealand)"
  ["en-PH"]="English (Philippines)"
  ["en-SG"]="English (Singapore)"
  ["en-TT"]="English (Trinidad and Tobago)"
  ["en-US"]="English (United States)"
  ["en-ZA"]="English (South Africa)"
  ["en-ZW"]="English (Zimbabwe)"
  ["eo"]="Esperanto"
  ["es"]="español"
  ["es-AR"]="español (Argentina)"
  ["es-BO"]="español (Bolivia)"
  ["es-CL"]="español (Chile)"
  ["es-CO"]="español (Colombia)"
  ["es-CR"]="español (Costa Rica)"
  ["es-DO"]="español (República Dominicana)"
  ["es-EC"]="español (Ecuador)"
  ["es-ES"]="español (España)"
  ["es-LA"]="español (de América Latina)"
  ["es-419"]="español (de América Latina)"
  ["es-GT"]="español (Guatemala)"
  ["es-HN"]="español (Honduras)"
  ["es-MX"]="español (México)"
  ["es-NI"]="español (Nicaragua)"
  ["es-PA"]="español (Panamá)"
  ["es-PE"]="español (Perú)"
  ["es-PR"]="español (Puerto Rico)"
  ["es-PY"]="español (Paraguay)"
  ["es-SV"]="español (El Salvador)"
  ["es-UY"]="español (Uruguay)"
  ["es-VE"]="español (Venezuela)"
  ["et"]="eesti"
  ["et-EE"]="eesti (Eesti)"
  ["eu"]="euskara"
  ["eu-ES"]="euskara (Espainia)"
  ["fa"]="فارسی"
  ["fa-IR"]="فارسی (ایران)"
  ["fi"]="suomi"
  ["fi-FI"]="suomi (Suomi)"
  ["fil"]="Filipino"
  ["fil-PH"]="Filipino (Pilipinas)"
  ["fil-PR"]="Filipino (Puerto Rico)"
  ["fo"]="føroyskt"
  ["fo-FO"]="føroyskt (Føroyar)"
  ["fr"]="français"
  ["fr-BE"]="français (Belgique)"
  ["fr-CA"]="français (Canada)"
  ["fr-CH"]="français (Suisse)"
  ["fr-FR"]="français (France)"
  ["fr-LU"]="français (Luxembourg)"
  ["fr-MC"]="français (Monaco)"
  ["gl"]="galego"
  ["gl-ES"]="galego (España)"
  ["gu"]="ગુજરાતી"
  ["gu-IN"]="ગુજરાતી (ભારત)"
  ["he"]="עברית"
  ["he-IL"]="עברית (ישראל)"
  ["hi"]="हिन्दी"
  ["hi-IN"]="हिन्दी (भारत)"
  ["hr"]="hrvatski"
  ["hr-BA"]="hrvatski (Bosna i Hercegovina)"
  ["hr-HR"]="hrvatski (Hrvatska)"
  ["hu"]="magyar"
  ["hu-HU"]="magyar (Magyarország)"
  ["hy"]="հայերեն"
  ["hy-AM"]="հայերեն (Հայաստան)"
  ["id"]="Bahasa Indonesia"
  ["id-ID"]="Bahasa Indonesia (Indonesia)"
  ["is"]="íslenska"
  ["is-IS"]="íslenska (Ísland)"
  ["it"]="italiano"
  ["it-CH"]="italiano (Svizzera)"
  ["it-IT"]="italiano (Italia)"
  ["ja"]="日本語"
  ["ja-JP"]="日本語 (日本)"
  ["ka"]="ქართული"
  ["ka-GE"]="ქართული (საქართველო)"
  ["kk"]="қазақ"
  ["kk-KZ"]="қазақ (Қазақстан)"
  ["km"]="ភាសាខ្មែរ"
  ["km-KH"]="ភាសាខ្មែរ (កម្ពុជា)"
  ["kn"]="ಕನ್ನಡ"
  ["kn-IN"]="ಕನ್ನಡ (ಭಾರತ)"
  ["ko"]="한국어"
  ["ko-KR"]="한국어 (대한민국)"
  ["kok"]="कोंकणी"
  ["kok-IN"]="कोंकणी (भारत)"
  ["ky"]="кыргызча"
  ["ky-KG"]="кыргызча (Кыргызстан)"
  ["lt"]="lietuvių"
  ["lt-LT"]="lietuvių (Lietuva)"
  ["lv"]="latviešu"
  ["lv-LV"]="latviešu (Latvija)"
  ["mi"]="te reo Māori"
  ["mi-NZ"]="te reo Māori (Aotearoa)"
  ["mk"]="македонски"
  ["mk-MK"]="македонски (Македонија)"
  ["ml"]="മലയാളം"
  ["ml-in"]="മലയാളം (ഇന്ത്യ)"
  ["mn"]="монгол"
  ["mn-MN"]="монгол (Монгол улс)"
  ["mr"]="मराठी"
  ["mr-IN"]="मराठी (भारत)"
  ["ms"]="Bahasa Melayu"
  ["ms-BN"]="Bahasa Melayu (Brunei)"
  ["ms-MY"]="Bahasa Melayu (Malaysia)"
  ["mt"]="Malti"
  ["mt-MT"]="Malti (Malta)"
  ["my"]="မြန်မာ"
  ["my-MM"]="မြန်မာ (မြန်မာ)"
  ["nb"]="norsk bokmål"
  ["nb-NO"]="norsk bokmål (Norge)"
  ["ne"]="नेपाली"
  ["ne-NP"]="नेपाली (नेपाल)"
  ["ne-IN"]="नेपाली (भारत)"
  ["nl"]="Nederlands"
  ["nl-BE"]="Nederlands (België)"
  ["nl-NL"]="Nederlands (Nederland)"
  ["nn"]="norsk nynorsk"
  ["nn-NO"]="norsk nynorsk (Norge)"
  ["no"]="norsk"
  ["no-NO"]="norsk (Norge)"
  ["ns"]="Sesotho"
  ["ns-ZA"]="Sesotho (South Africa)"
  ["pa"]="ਪੰਜਾਬੀ"
  ["pa-IN"]="ਪੰਜਾਬੀ (ਭਾਰਤ)"
  ["pl"]="polski"
  ["pl-PL"]="polski (Polska)"
  ["pt"]="português"
  ["pt-BR"]="português (Brasil)"
  ["pt-PT"]="português (Portugal)"
  ["qu"]="Runa Simi"
  ["qu-BO"]="Runa Simi (Bolivia)"
  ["qu-EC"]="Runa Simi (Ecuador)"
  ["qu-PE"]="Runa Simi (Perú)"
  ["ro"]="română"
  ["ro-RO"]="română (România)"
  ["ru"]="русский"
  ["ru-RU"]="русский (Россия)"
  ["sa"]="संस्कृतम्"
  ["sa-IN"]="संस्कृतम् (भारतम्)"
  ["se"]="davvisámegiella"
  ["se-FI"]="davvisámegiella (Suopma)"
  ["se-NO"]="davvisámegiella (Norga)"
  ["se-SE"]="davvisámegiella (Ruoŧŧa)"
  ["si"]="සිංහල"
  ["si-LK"]="සිංහල (ශ්රී ලංකා)"
  ["sk"]="slovenčina"
  ["sk-SK"]="slovenčina (Slovensko)"
  ["sl"]="slovenščina"
  ["sl-SI"]="slovenščina (Slovenija)"
  ["sq"]="shqip"
  ["sq-AL"]="shqip (Shqipëria)"
  ["sr-BA"]="српски (Босна и Херцеговина)"
  ["sr-RS"]="српски (Република Србија)"
  ["sr-SP"]="српски (Србија)"
  ["sv"]="svenska"
  ["sv-FI"]="svenska (Finland)"
  ["sv-SE"]="svenska (Sverige)"
  ["sw"]="Kiswahili"
  ["sw-KE"]="Kiswahili (Kenya)"
  ["syr"]="ܣܘܪܝܝܐ"
  ["syr-SY"]="ܣܘܪܝܝܐ (ܣܘܪܝܐ)"
  ["ta"]="தமிழ்"
  ["ta-IN"]="தமிழ் (இந்தியா)"
  ["te"]="తెలుగు"
  ["te-IN"]="తెలుగు (భారతదేశం)"
  ["th"]="ไทย"
  ["th-TH"]="ไทย (ไทย)"
  ["tl"]="Filipino"
  ["tl-PH"]="Filipino (Pilipinas)"
  ["tn"]="Setswana"
  ["tn-ZA"]="Setswana (Aforika Borwa)"
  ["tr"]="Türkçe"
  ["tr-TR"]="Türkçe (Türkiye)"
  ["ts"]="Xitsonga"
  ["tt"]="Татарча"
  ["tt-RU"]="Татарча (Россия)"
  ["uk"]="українська"
  ["uk-UA"]="українська (Україна)"
  ["ur"]="اردو"
  ["ur-PK"]="اردو (پاکستان)"
  ["uz"]="o‘zbek"
  ["uz-UZ"]="o‘zbek (Oʻzbekiston)"
  ["vi"]="Tiếng Việt"
  ["vi-VI"]="Tiếng Việt (Việt Nam)"
  ["vi-VN"]="Tiếng Việt (Việt Nam)"
  ["xh"]="isiXhosa"
  ["xh-ZA"]="isiXhosa (South Africa)"
  ["zh"]="中文"
  ["zh-Hans"]="简体中文"
  ["zh-Hant"]="繁體中文"
  ["zh-CN"]="中文 (中国)"
  ["zh-HK"]="中文 (香港)"
  ["zh-MO"]="中文 (澳门)"
  ["zh-SG"]="中文 (新加坡)"
  ["zh-TW"]="中文 (台灣)"
  ["zu"]="isiZulu"
  ["zu-ZA"]="isiZulu (South Africa)"
)
# 对所有键值进行小写化复制，以解决文件判断时的大小写问题
for lang in ${!lang_map[@]}; do
  if [ "${lang,,}" != "$lang" ]; then
    lang_map[${lang,,}]=${lang_map[$lang]}
  fi
done

# 预定义需要优先处理的字幕语言代码
preset_lang_codes=(zh zh-hans zh-hant zh-cn zh-hk zh-mo zh-tw zh-sg en en-us en-gb en-au en-ca en-nz en-sg en-bz en-cb en-ie en-in en-jm en-ng en-ph en-tt en-za en-zw)

# 字幕类型
# subtitle_types=('' 'cc' 'sdh' 'forced' 'forced[narrative]')
# declare -A subtitle_type_names=(['sdh']='CC' ['forced']='Forced' ['forced[narrative]']='Forced')
subtitle_types=('' 'cc' 'sdh')
declare -A subtitle_type_names=(['sdh']='CC')

# 处理第一个参数，存在则将其作为源路径，否则以当前路径为源路径
if [ $# -ge 1 ] && [ -d "$1" ]; then
  source_dir=${1%*/}
else
  source_dir=.
fi
# 处理第二个参数，存在则将其作为目的路径，否则以源路径为目的路径
if [ $# -ge 2 ]; then
  target_dir=${2%*/}
else
  target_dir=$source_dir
fi
# 处理第三个参数，存在则将其作为 mkvmerge 的附加参数
if [ $# -ge 3 ]; then
  mkvcmd_params=" $3"
fi

# 默认 IFS 分隔符为空格，对于文件名有空格的会出错，这里以换行符为分隔符
oldIFS=$IFS
IFS=$'\n'

# 根据操作系统类型设置 find 命令参数
if [ "$(uname)" == "Darwin" ]; then
  find_param="-s"
else
  find_param=""
fi

# 获取 Bash 主要版本号和次要版本号
major_version=$(echo $BASH_VERSION | cut -d '.' -f 1)
minor_version=$(echo $BASH_VERSION | cut -d '.' -f 2)

# 遍历处理源路径中的所有 mp4 文件，不包括子目录
for file in $(find $find_param $source_dir -maxdepth 1 -type f \( -iname "*.mp4" ! -iname ".*" \)); do
  # 取文件基本名称
  filename=$(basename "$file")
  matchname=${filename%.*}

  # 判断版本是否大于等于 5.2
  if [[ $major_version -gt 5 ]] || [[ $major_version -eq 5 && $minor_version -ge 2 ]]; then
    # 在 5.2 以上版本执行的操作
    # 字符串替换中的 & 符号是 bash 5.2 的特性
    matchname=${matchname//[\[\]\*\?]/\\&}
  else
    # 在 5.2 以下版本执行的操作
    matchname=${matchname//\[/\\[}
    matchname=${matchname//\]/\\]}
    matchname=${matchname//\*/\\*}
    matchname=${matchname//\?/\\?}
  fi

  declare -A srt_valid=()
  lang_valid=()
  # 遍历当前 mp4 对应的所有字幕文件
  for tmp_srt in $(find $source_dir -maxdepth 1 -type f \( -iname "${matchname}*.srt" -o -iname "${matchname}*.ass" \)); do
    # 用正则表达式匹配字幕文件名，匹配成功则将其加入有效字幕列表，为了大小写不敏感，这里将字符转换为小写后再进行匹配
    if [[ "${tmp_srt,,}" =~ [.-_]([a-z]{2,3}([-_][a-z0-9]{2,})?)([.-_\[](cc|sdh|forced(\[narrative\])?)\]?)?\.(srt|ass)$ ]]; then
      tmp_srt_lang=${BASH_REMATCH[1],,}
      tmp_srt_type=${BASH_REMATCH[4],,}
      if [ "${lang_map[$tmp_srt_lang]}" == "" ]; then
        echo "lang $tmp_srt_lang is unknown."
        exit
      fi
      srt_valid["${tmp_srt_lang}.${tmp_srt_type}"]="$tmp_srt"
      lang_valid+=("$tmp_srt_lang")
      # 清除字幕中的字体格式标签
      extname=${tmp_srt##*.}
      if [ "${extname,,}" == "srt" ]; then
        sed -i '' 's/<[^>]*>//g' "$tmp_srt"
      fi
    else
      echo "$tmp_srt is not a valid subtitle filename."
    fi
  done

  # 生成有效字幕语言代码列表
  lang_codes=()
  for lang in ${preset_lang_codes[@]}; do
    if [[ "${lang_valid[@]/${lang}/}" != "${lang_valid[@]}" ]]; then
      lang_codes[${#lang_codes[@]}]=$lang
    fi
  done
  lang_codes+=("${lang_valid[@]}")
  lang_codes=($(awk -v RS=' ' '!a[$1]++' <<<${lang_codes[@]}))

  # 每个文件的初始命令字符串
  mkmkvcmd="mkvmerge -o \"$target_dir/${filename%.*}.mkv\" -S --no-global-tags \"$file\""

  # 是否已经为当前文件设置过 default flag ，初始为 no
  # 一旦设置过 default flag ，则此值必须同时设为非 no
  # 目的是确保每一个生成的 mkv 文件只有一个字幕流为默认流
  have_default="no"

  # 遍历语言代码
  for lang_code in ${lang_codes[@]}; do
    # 循环处理字幕类型，用这种循环方式遍历数组是因为要处理空元素
    for ((i = 0; $i < ${#subtitle_types[@]}; i++)); do
      subtitle_type=${subtitle_types[$i]}
      # 取扩展字幕类型对应的名称，用于设置 track name
      if [ "$subtitle_type" == "" ]; then
        subtitle_type_name=""
      elif [ "${subtitle_type_names[$subtitle_type]}" != "" ]; then
        subtitle_type_name=" [${subtitle_type_names[$subtitle_type]}]"
      else
        subtitle_type_name=" [${subtitle_type^^}]"
      fi

      # 判断文件是否存在
      srt_file=${srt_valid["${lang_code}.${subtitle_type}"]}
      if [ "$srt_file" != "" ]; then
        # 设置 degault flag ，确保一个文件只有一条默认字幕流
        if [ $have_default == "no" ]; then
          default_flag="yes"
          have_default="yes"
        else
          default_flag="no"
        fi
        # 拼接至命令字符串中
        mkmkvcmd+=" --sub-charset 0:UTF-8 --language 0:$lang_code --track-name 0:\"${lang_map[$lang_code]}$subtitle_type_name\" --default-track-flag 0:$default_flag \"$srt_file\""
      fi
    done
  done

  # 拼接附加参数
  mkmkvcmd+=$mkvcmd_params

  # 显示并执行最终拼接后的命令
  echo $mkmkvcmd
  eval $mkmkvcmd
done

# 恢复原有 IFS 分隔符
IFS=$oldIFS
