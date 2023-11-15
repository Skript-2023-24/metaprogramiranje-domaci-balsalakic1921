require 'google_drive'
require 'C:\Users\Balsa\Desktop\untitled\untitled\coolum_operation.rb'
require 'C:\Users\Balsa\Desktop\untitled\untitled\sintax.rb'

class TableImplementation

  include Enumerable

  def initialize(session, num)
    @table = session.spreadsheet_by_key("1p5S3RwPA-xaFVx-r4jdSjQEl8TC5nY-_cxD6BYGndKg").worksheets[num]
    @colums = Hash.new
    @table.rows[0].each_with_index {|value, index| @colums[value.to_s.downcase.gsub(' ','')] = index }
  end

  def to_array
    @table.rows.map(&:to_a)
  end

  def each(&block)
    @table.rows.each do |row|
      row.each(&block)
    end
  end

  def row(value)
    return @table.rows[value.to_i - 1]
  end

  def [](colum)
    colums = []
    splitedColumn = colum.split("\"")

    @table.rows.each do |row|
      colums.append(row[@colums[splitedColumn[0].to_s.downcase.gsub(' ', '')].to_i])
    end

    Sintax.new(@table, colums, @colums[splitedColumn[0].to_s.downcase.gsub(' ', '')].to_i)
  end

  def method_missing(colum)
    colums = []

    @table.rows.each do |row|
      if lookTotalAndSub(row) != 1
        row[@colums[colum.to_s.downcase.gsub(' ', '')].to_i]=~/[0-9]/ ? colums.append(row[@colums[colum.to_s.downcase.gsub(' ', '')].to_i].to_i) : next
      end
    end

    CoolumOperation.new(@table, colums)
  end

  def lookTotalAndSub(row)

    check = 0

    (0...row.length).each do |col|
      row[col]=~/total/ || row[col]=~/subtotal/ ? check = 1 : next
    end

    return check.to_i
  end

  def lookEmpty(row)

    check = 0

    (0...row.length).each{|col| row[col] == "" ? check+=1 : break}

    return check == row.length ? 1 : 0

  end
  
  def +(table2)
    if @table.rows[1].eql?(table2.getTable.rows[1])
      table2.getTable.rows.each_with_index do |row, index|
        index > 1? @table.insert_rows(@table.num_rows + 1, [row]) : next
        @table.save
      end
    end
  end

  def -(table2)

    arrDel = []

    @table.rows.each_with_index do |row, index|
      table2.getTable.rows.each do |row2|
        checkRow(row, row2) == 1 && index > 1 ? arrDel.append(index+1) : next
        break
      end
    end

    (0...arrDel.length).each do |index|
      @table.delete_rows(arrDel[index] - index, 1)
      @table.save
    end

  end

  def checkRow(row1, row2)

    check = 0

    (0...row1.length).each do|i|
      row1[i] == row2[i] ? check+=1 : break
    end

    return check == @table.num_cols ? 1 : 0
  end
  
  def getTable
    @table
  end

  def to_s
    @table.rows.each_with_index do | row, index |

      print "\n"

      if lookEmpty(row) == 1
        print "_______________prazan red___________________"
        next
      end

      row.each do |col|
        print col + " | "
      end

    end
  end
end

session = GoogleDrive::Session.from_config("config.json")

table = TableImplementation.new(session, 0)
table1 = TableImplementation.new(session, 1)



# p table.to_array # 1. Biblioteka može da vrati dvodimenzioni niz sa vrednostima tabele

# p table.row(3) # 2. Moguće je pristupati redu preko t.row(1)
# p table.row(3)[2] # 2.  i pristup njegovim elementima po sintaksi niza.

# table.each do |cell|  # 3. Mora biti implementiran Enumerable modul(each funkcija), gde se vraćaju sve ćelije unutar tabele, sa leva na desno.
#   print cell + " "
# end

# puts table["Druga kolona"] # 4.1 Biblioteka vraća celu kolonu kada se napravi upit
# p table["Druga kolona"][3]  # 4.2 Biblioteka omogućava pristup vrednostima unutar kolone po sledećoj sintaksi t[“Prva Kolona”][1] za pristup drugom elementu te kolone
# p table["Prva kolona"][3] = 1000 # 4.3 Biblioteka omogućava podešavanje vrednosti unutar ćelije po sledećoj sintaksi

# p table.trecakolona.sum  # Subtotal/Average  neke kolone se može sračunati preko sledećih sintaksi t.prvaKolona.sum i t.prvaKolona.avg
# p table.trecakolona.avg

# p table.indeks.rn2310  # Primer sintakse: t.indeks.rn2310, ovaj kod će vratiti red studenta čiji je indeks rn2310

# p table.prvakolona.map{ |cell| cell + 10 }  # Kolona mora da podržava funkcije kao što su map, select,reduce.
# p table.prvakolona.select{|cell| cell.even? }


# p table.indeks.rn111 # TOTAL ILI SUB

# table+table1 # sabiranje tabela
# table-table1 # oduzimanje tabla

# table.to_s # prepoznavanje praznog reda



