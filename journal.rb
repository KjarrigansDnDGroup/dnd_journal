Entry = Struct.new :session_id, :name, :amount, :value, :storage, :comment

class Integer
  def gp
    self * 100
  end

  def sp
    self * 10
  end

  def cp
    self
  end
end

class Coins
  attr_reader :copperlings
  attr_reader :gold
  attr_reader :silver
  attr_reader :copper
  def initialize(int)
    pre = int < 0 ? -1 : 1
    int = int.abs
    
    @copperlings = int

    @gold, remaining_copperlings = copperlings.divmod(100)
    @gold *= pre
    @silver, remaining_copperlings = remaining_copperlings.divmod(10)
    @silver *= pre
    @copper = remaining_copperlings
    @copper *= pre
  end

  # Math
  def +(val)
    Coins.new(self.to_i + val.to_i)
  end

  def -(val)
    Coins.new(self.to_i - val.to_i)
  end

  def *(val)
    Coins.new(self.to_i * val)
  end

  def /(val)
    Coins.new(self.to_i / val)
  end

  # Import
  def self.from_int(val)
    new(val.to_i)
  end

  def self.from_string(str)
    cop = nil
    str.scan(/(\d{1,}\s?(g|s|c)?p?)/).each do |value, mid|
      cop ||= 0
      cop += value.to_i * multiplier(mid)
    end
    new(cop)
  end

  # Export
  alias_method :to_i, :copperlings
  def to_h
    hsh = Hash.new(0)
    hsh["gp"] = gold
    hsh["sp"] = silver
    hsh["cp"] = copper
    hsh
  end

  def each(&block)
    to_h.each(&block)
  end

  def to_s
    to_h.to_a.map(&:reverse).delete_if{|v,k| v == 0}.flatten.join(' ')
  end

  # Helper
  def self.multiplier(char)
    case char
    when /g/ then 100
    when /s/ then 10
    when /c/ then 1
    else 0
    end
  end
end

require 'yaml'

class Journal
  def initialize
    @db = File.new('journal.db', 'a+')
    load
  end

  def load
    @entries = YAML.load(@db.read)
    @entries = [] unless @entries
  end

  def clear
    @entries.clear
    @db = File.new('journal.db', 'w+')
  end

  def append(entry)
    @db.puts "---\n" if @entries.empty?

    @entries << entry
    @db.puts [entry].to_yaml.split("\n")[1..-1].join("\n")
    @db.flush
  end

  def entries
    @entries.dup
  end

  def current_coins
    Coins.new(@entries.map{|e| e.value }.inject(&:+)).to_s
  end

  def export_as_html(reverse: false)
    html = "<table><tr><th>Lfd.</th>"
    html += Entry.members.map{|head| "<th>#{head.to_s.capitalize}</th>" }.join
    html += "</tr>"
    list = @entries
    list = list.reverse if reverse
    list.each.with_index(1) do |entry,idx|
      idx = list.size - idx + 1 if reverse
      html += "<tr><td>#{idx}</td>"
      entry.each_pair do |key,value|
        value = Coins.new(value) if key == :value
        html += "<td>#{value.to_s.empty? ? '-' : value.to_s}</td>"
      end
      html += "</tr>"
    end
    html + "</table>"
  end

  def close
    @db.close
  end

  private
  def coins_to_s(value)
    value
  end
end

j = Journal.new
j.clear
j.append Entry.new 3, '', 0, 50.gp, '', 'Anzahlung Quest #2 - "Kurier Mühlenberge"'
j.append Entry.new 3, '', 0, -50.gp, '', 'je 10gp an die Gruppenmitglieder verteilt'
j.append Entry.new 3, '', 0, 143.gp, 'Gwyn', 'Direktfund 1. Kampf mit Goblins'
j.append Entry.new 4, '', 0, 350.gp, 'Gwyn', 'Direktfund 2. Kampf mit Goblins und Myrdral'
j.append Entry.new 4, 'Scoll of Identification', 0, -110.gp, 'direkt verwendet', 'von BM in Tanne#Fähre gekauft und zur Identifikation des Erzmagierrings verwendet'
j.append Entry.new 5, '', 0, 100.gp, 'Gwyn', 'Verkauf des kompletten Loot aus den beiden Goblinkämpfen an Armin in Mühlenberge'
j.append Entry.new 5, 'Service', 0, -1.gp, '', 'Bezahlung des Händlers der uns und unseren verletzten Gefährten mitnimmt.'
j.append Entry.new 5, 'Light Horse', 1, -90.gp, '', 'Leichtes Pferd und einen Transportsattel gekauft'
j.append Entry.new 6, '', 0, 75.gp, 'Gwyn', 'Belohnung Qest #2 - "Kurier Mühlenberge"'
j.append Entry.new 6, 'Kost & Logis', 0, -4.gp, '', ''
j.append Entry.new 6, 'Rations', 0, -1.gp, '', ''
j.append Entry.new 7, 'Service', 0, -50.gp, '', 'Spende an den Tempel für den Versuch Tarsos Wunde zu heilen'
j.append Entry.new 7, 'Service', 0, -5.gp, '', 'Kurier beauftragt, den General über unser Vorhaben nach Süden zu gehen zu informieren und unser Pferd nach Otternburg zu Gwyns Eltern zu bringen.'
j.append Entry.new 7, 'Kost & Logis', 0, -4.gp, '', ''
j.append Entry.new 7, 'Rations', 0, -1.gp, '', ''
j.append Entry.new 8, 'Scale Mail', 1, -50.gp, '', 'Rüstung für Tarso'
j.append Entry.new 8, 'Scale Mail', 1, -50.gp, '', 'Rüstung für Eldgrimm'
j.append Entry.new 8, 'Bullseye Latern', 2, -24.gp, '', 'Vorbereitung für Zwergenfestung'
j.append Entry.new 8, 'Chalk', 10, -1.sp, '', 'Vorbereitung für Zwergenfestung'
j.append Entry.new 11, '', 0, 200.gp, 'Gwyn', 'Direktfund Kampf mit Goblinoiden'
j.append Entry.new 12, 'Kost & Logis', 0, -6.gp, '', ''
j.append Entry.new 14, 'Kost & Logis', 0, -6.gp, '', ''
j.append Entry.new 15, 'Kost & Logis', 0, -6.gp, '', ''
j.append Entry.new 15, 'Thieves Tools', 0, 0.gp, 'Talin', 'Bei zwei vermeintlichen Diebsleichen gefunden'
j.append Entry.new 15, '', 0, 20.gp, '', 'In einem Geheimversteck in der Kanalisation'
j.append Entry.new 15, 'Valuable Carpet', 0, 0.gp, 'Zaubersack', 'In einem Geheimversteck in der Kanalisation'
j.append Entry.new 16, 'Ink & 5x Parchment', 0, -9.gp, 'Gwyn', 'Für die Zukunft...'
j.append Entry.new 16, '20x Arrow', 0, -1.gp, 'Talin', ''
j.append Entry.new 16, 'Questbelohnung', 0, 120.gp, '', '20g Boni wegen guter Dienste'
j.append Entry.new 17, 'Kost & Logis', 0, -10.gp, '', '1g / pro Nacht und Tag Logis, 5s / Nacht / Tag Kost'
j.append Entry.new 17, 'Gather Information', 0, -2.gp, '', 'Suche nach Gerhard Osterhagen'
j.append Entry.new 19, 'Kost & Logis', 0, -10.gp, '', '1g / pro Nacht und Tag Logis, 5s / Nacht / Tag Kost'
j.append Entry.new 19, 'Trinkgelder', 0, -5.sp, '', 'für den Fiedler'
j.append Entry.new 19, 'Wirtshaus', 0, -11.gp, '', 'Ein stimmungsvoller Abend mit Wein, Tanz und Gesang'
j.append Entry.new 19, 'Verkauf Mythrilbarren', 0, 1100.gp, '', 'an Thurgrom Steinherz 10% rausgehandelt'
j.append Entry.new 19, 'Handel', 0, 13.gp, 'Gwyn', 'Teppich verkauft (siehe Abend #15 / Lfd. 26) und ordentliche, bequeme Reisegewandung für Gwyn'
j.append Entry.new 19, 'Kost & Logis', 0, -10.gp, '', '1g / pro Nacht und Tag Logis, 5s / Nacht / Tag Kost'
j.append Entry.new 19, 'Wirtshaus', 0, -11.gp, '', 'Ein stimmungsvoller Abend mit Wein, Tanz und Gesang'
j.append Entry.new 19, 'Kost & Logis', 0, -14.gp, '', ''
j.append Entry.new 19, '', 0, 0.gp, '', 'Anzahlung Eskorte Goldbeck->Otternburg jeder 10g in die eigene Tasche'
j.append Entry.new 19, '', 0, 288.gp, '', 'Belohung Eskorte (#39) 48g pro Kopf'
j.append Entry.new 21, 'Battleaxe (Masterwork)', 0, -310.gp,  'Talin', 'Shoppingtour'
j.append Entry.new 23, 'Karnival Teil 1', 0, -265.gp, '', 'Wir hatten einen spannenden Tag (Details siehe Abend #23)'
j.append Entry.new 23, 'Identify', 0, -100.gp, '', 'Gwyn identifiziert die magische Lampe aus dem Turm'
j.append Entry.new 23, 'Karnival Teil 2', 0, 410.gp, '', 'Wir hatten einen spannenden Tag (Details siehe Abend #24)'

puts "<html>"
puts "<head>"
puts "<meta charset='utf-8'/>"
puts "</head>"
puts "<body>"
puts "<h1>Finanzbuchhaltung</h1>"
puts "<h2>Aktueller Kontostand - #{j.current_coins}</h2>"
puts j.export_as_html(reverse: true) # Show latest first
puts "</body>"
puts "</html>"

j.close


# Gwyns Budget
# earn 8.gp, 'as start money'
# pay 1.gp, 'for bolts'
# earn 10.gp, 'for Quest#Bengar'
# earn 10.gp, 'for Quest#Karawane Goldbeck-Otternburg'
