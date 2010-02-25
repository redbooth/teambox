// render from /Users/charles/Documents/Rails/teambox/app/javascripts/i18n/strftime.erb// es

Object.extend(Date.prototype, {
  strftime_es: function(format) {
    var day = this.getDay(), month = this.getMonth();
    var hours = this.getHours(), minutes = this.getMinutes();
    function pad(num) { return num.toPaddedString(2); };

    return format.gsub(/\%([aAbBcdDHiImMpSwyY])/, function(part) {
      switch(part[1]) {
        case 'a': return $w("Dom Lun Mar Mié Jue Vie Sáb")[day]; break;
        case 'A': return $w("Domingo Lunes Martes Miércoles Jueves Viernes Sábado")[day]; break;
        case 'b': return $w(" Ene Feb Mar Abr May Jun Jul Ago Sep Oct Nov Dec")[month]; break;
        case 'B': return $w(" Enero Febrero Marzo Abril Mayo Junio Julio Agosto Septiembre Octubre Noviembre Diciembre")[month]; break;
        case 'c': return this.toString(); break;
        case 'd': return this.getDate(); break;
        case 'D': return pad(this.getDate()); break;
        case 'H': return pad(hours); break;
        case 'i': return (hours === 12 || hours === 0) ? 12 : (hours + 12) % 12; break;
        case 'I': return pad((hours === 12 || hours === 0) ? 12 : (hours + 12) % 12); break;
        case 'm': return pad(month + 1); break;
        case 'M': return pad(minutes); break;
        case 'p': return hours > 11 ? 'PM' : 'AM'; break;
        case 'S': return pad(this.getSeconds()); break;
        case 'w': return day; break;
        case 'y': return pad(this.getFullYear() % 100); break;
        case 'Y': return this.getFullYear().toString(); break;
      }
    }.bind(this));
  }
});// it

Object.extend(Date.prototype, {
  strftime_it: function(format) {
    var day = this.getDay(), month = this.getMonth();
    var hours = this.getHours(), minutes = this.getMinutes();
    function pad(num) { return num.toPaddedString(2); };

    return format.gsub(/\%([aAbBcdDHiImMpSwyY])/, function(part) {
      switch(part[1]) {
        case 'a': return $w("Dom Lun Mar Mer Gio Ven Sab")[day]; break;
        case 'A': return $w("Domenica Lunedì Martedì Mercoledì Giovedì Venerdì Sabato")[day]; break;
        case 'b': return $w(" Gen Feb Mar Apr Mag Giu Lug Ago Set Ott Nov Dic")[month]; break;
        case 'B': return $w(" Gennaio Febbraio Marzo Aprile Maggio Giugno Luglio Agosto Settembre Ottobre Novembre Dicembre")[month]; break;
        case 'c': return this.toString(); break;
        case 'd': return this.getDate(); break;
        case 'D': return pad(this.getDate()); break;
        case 'H': return pad(hours); break;
        case 'i': return (hours === 12 || hours === 0) ? 12 : (hours + 12) % 12; break;
        case 'I': return pad((hours === 12 || hours === 0) ? 12 : (hours + 12) % 12); break;
        case 'm': return pad(month + 1); break;
        case 'M': return pad(minutes); break;
        case 'p': return hours > 11 ? 'PM' : 'AM'; break;
        case 'S': return pad(this.getSeconds()); break;
        case 'w': return day; break;
        case 'y': return pad(this.getFullYear() % 100); break;
        case 'Y': return this.getFullYear().toString(); break;
      }
    }.bind(this));
  }
});// en

Object.extend(Date.prototype, {
  strftime_en: function(format) {
    var day = this.getDay(), month = this.getMonth();
    var hours = this.getHours(), minutes = this.getMinutes();
    function pad(num) { return num.toPaddedString(2); };

    return format.gsub(/\%([aAbBcdDHiImMpSwyY])/, function(part) {
      switch(part[1]) {
        case 'a': return $w("Sun Mon Tue Wed Thu Fri Sat")[day]; break;
        case 'A': return $w("Sunday Monday Tuesday Wednesday Thursday Friday Saturday")[day]; break;
        case 'b': return $w(" Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec")[month]; break;
        case 'B': return $w(" January February March April May June July August September October November December")[month]; break;
        case 'c': return this.toString(); break;
        case 'd': return this.getDate(); break;
        case 'D': return pad(this.getDate()); break;
        case 'H': return pad(hours); break;
        case 'i': return (hours === 12 || hours === 0) ? 12 : (hours + 12) % 12; break;
        case 'I': return pad((hours === 12 || hours === 0) ? 12 : (hours + 12) % 12); break;
        case 'm': return pad(month + 1); break;
        case 'M': return pad(minutes); break;
        case 'p': return hours > 11 ? 'PM' : 'AM'; break;
        case 'S': return pad(this.getSeconds()); break;
        case 'w': return day; break;
        case 'y': return pad(this.getFullYear() % 100); break;
        case 'Y': return this.getFullYear().toString(); break;
      }
    }.bind(this));
  }
});// ca

Object.extend(Date.prototype, {
  strftime_ca: function(format) {
    var day = this.getDay(), month = this.getMonth();
    var hours = this.getHours(), minutes = this.getMinutes();
    function pad(num) { return num.toPaddedString(2); };

    return format.gsub(/\%([aAbBcdDHiImMpSwyY])/, function(part) {
      switch(part[1]) {
        case 'a': return $w("Dg Di Dm Dc Dj Dv Ds")[day]; break;
        case 'A': return $w("Diumenge Dilluns Dimarts Dimecres Dijous Divendres Dissabte")[day]; break;
        case 'b': return $w(" Gen Feb Mar Abr Maig Jun Jul Ago Sep Oct Nov Dec")[month]; break;
        case 'B': return $w(" Gener Febrer Març Abril Maig Juny Juliol Agost Setembre Octubre Novembre Desembre")[month]; break;
        case 'c': return this.toString(); break;
        case 'd': return this.getDate(); break;
        case 'D': return pad(this.getDate()); break;
        case 'H': return pad(hours); break;
        case 'i': return (hours === 12 || hours === 0) ? 12 : (hours + 12) % 12; break;
        case 'I': return pad((hours === 12 || hours === 0) ? 12 : (hours + 12) % 12); break;
        case 'm': return pad(month + 1); break;
        case 'M': return pad(minutes); break;
        case 'p': return hours > 11 ? 'PM' : 'AM'; break;
        case 'S': return pad(this.getSeconds()); break;
        case 'w': return day; break;
        case 'y': return pad(this.getFullYear() % 100); break;
        case 'Y': return this.getFullYear().toString(); break;
      }
    }.bind(this));
  }
});// fr

Object.extend(Date.prototype, {
  strftime_fr: function(format) {
    var day = this.getDay(), month = this.getMonth();
    var hours = this.getHours(), minutes = this.getMinutes();
    function pad(num) { return num.toPaddedString(2); };

    return format.gsub(/\%([aAbBcdDHiImMpSwyY])/, function(part) {
      switch(part[1]) {
        case 'a': return $w("Dim Lun Mar Mer Jeu Ven Sam")[day]; break;
        case 'A': return $w("Dimanche Lundi Mardi Mercredi Jeudi Vendredi Samedi")[day]; break;
        case 'b': return $w(" Jan Fév Mar Avr Mai Juin Juil Août Sep Oct Nov Dec")[month]; break;
        case 'B': return $w(" Janvier Février Mars Avril Mai Juin Juillet Août Septembre Octobre Novembre Décembre")[month]; break;
        case 'c': return this.toString(); break;
        case 'd': return this.getDate(); break;
        case 'D': return pad(this.getDate()); break;
        case 'H': return pad(hours); break;
        case 'i': return (hours === 12 || hours === 0) ? 12 : (hours + 12) % 12; break;
        case 'I': return pad((hours === 12 || hours === 0) ? 12 : (hours + 12) % 12); break;
        case 'm': return pad(month + 1); break;
        case 'M': return pad(minutes); break;
        case 'p': return hours > 11 ? 'PM' : 'AM'; break;
        case 'S': return pad(this.getSeconds()); break;
        case 'w': return day; break;
        case 'y': return pad(this.getFullYear() % 100); break;
        case 'Y': return this.getFullYear().toString(); break;
      }
    }.bind(this));
  }
});// de

Object.extend(Date.prototype, {
  strftime_de: function(format) {
    var day = this.getDay(), month = this.getMonth();
    var hours = this.getHours(), minutes = this.getMinutes();
    function pad(num) { return num.toPaddedString(2); };

    return format.gsub(/\%([aAbBcdDHiImMpSwyY])/, function(part) {
      switch(part[1]) {
        case 'a': return $w("Son Mon Die Mit Don Fre Sam")[day]; break;
        case 'A': return $w("Sonntag Montag Dienstag Mittwoch Donnerstag Freitag Samstag")[day]; break;
        case 'b': return $w(" Jan Feb Mär Apr Mai Jun Jul Aug Sep Okt Nov Dez")[month]; break;
        case 'B': return $w(" Januar Februar März April Mai Juni Juli August September Oktober November Dezember")[month]; break;
        case 'c': return this.toString(); break;
        case 'd': return this.getDate(); break;
        case 'D': return pad(this.getDate()); break;
        case 'H': return pad(hours); break;
        case 'i': return (hours === 12 || hours === 0) ? 12 : (hours + 12) % 12; break;
        case 'I': return pad((hours === 12 || hours === 0) ? 12 : (hours + 12) % 12); break;
        case 'm': return pad(month + 1); break;
        case 'M': return pad(minutes); break;
        case 'p': return hours > 11 ? 'PM' : 'AM'; break;
        case 'S': return pad(this.getSeconds()); break;
        case 'w': return day; break;
        case 'y': return pad(this.getFullYear() % 100); break;
        case 'Y': return this.getFullYear().toString(); break;
      }
    }.bind(this));
  }
});