
@php
$value=function($key,$fallback='') { $v=old($key,$fallback); return is_scalar($v)?(string)$v:''; };
@endphp
<div class="profile-field"><label for="category-name">Category name</label><input id="category-name" name="name" required maxlength="100" value="{{ $value('name',$category->name ?? '') }}"></div>
<div class="profile-field"><label for="category-description">Description (optional)</label><textarea id="category-description" name="description" rows="3" maxlength="5000">{{ $value('description',$category->description ?? '') }}</textarea></div>
