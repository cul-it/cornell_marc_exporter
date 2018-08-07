class MARCModel < ASpaceExport::ExportModel
  model_for :marc21

  include JSONModel

  
  def self.from_resource(obj, opts={})
    marc = self.from_archival_object(obj,opts)
    marc.apply_map(obj, @resource_map)
    marc.leader_string = "00000cp$ aa2200000 a 4500"
    marc.leader_string[7] = obj.level == 'item' ? 'm' : 'c'

    marc.controlfield_string = assemble_controlfield_string(obj)

    marc
  end

  def self.assemble_controlfield_string(obj)
    date = obj.dates[0] || {}
    string = obj['system_mtime'].scan(/\d{2}/)[1..3].join('')
    #doesn't check item type before assigning date as single to accommodate single collections
    string += date['date_type'] == 'single' ? 's' : 'i'
    string += date['begin'] ? date['begin'][0..3] : "    "
    string += date['end'] ? date['end'][0..3] : "    "
    string += "nyu"
    18.times { string += ' ' }
    string += (obj.language || '|||')
    string += ' d'

    string
  end


  def handle_repo_code(repository,langcode)
  
    df('040', ' ', ' ').with_sfs(['a', 'NIC'], ['b', langcode],['c', 'NIC'])

  end

def handle_language(langcode)
  #blocks output of 041
end



def handle_extents(extents)
  extents.each do |ext|
    e = ext['number']
    t =  "#{I18n.t('enumerations.extent_extent_type.'+ext['extent_type'], :default => ext['extent_type'])}"

    

    df!('300').with_sfs(['a', e], ['f', t])
  end
end


def handle_id(*ids)
  ids.reject!{|i| i.nil? || i.empty?}
  df('099', ' ', '9').with_sfs(['a', ids.join('.')])
end



end