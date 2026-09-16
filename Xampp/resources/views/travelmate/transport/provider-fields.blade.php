@php
$pv=function($key,$fallback=''){ $v=old($key,$fallback);return is_scalar($v)?(string)$v:''; };
@endphp
<label>Company name<input required name="company_name" maxlength="150" value="{{ $pv('company_name',$provider->company_name??'') }}"></label><label>Description<textarea name="description" maxlength="5000">{{ $pv('description',$provider->description??'') }}</textarea></label><p>These are public business contact numbers. At least one is needed to submit a service.</p>
<div class="profile-row">@for($i=0;$i<5;$i++)<label>Contact {{ $i+1 }}<input name="phones[]" maxlength="20" value="{{ $pv('phones.'.$i,$phones[$i]??'') }}" placeholder="Business phone number"></label>@endfor</div>
